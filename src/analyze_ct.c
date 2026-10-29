/* analyze_ct.c -- class-body code run when the program is compiled.

   A class or module body sometimes defines a family of constants and
   classes from a table, with a loop the body runs once when its file loads:

     module HTTPStatus
       StatusMessage = { 200 => 'OK', 404 => 'Not Found' }
       CodeToError = {}
       StatusMessage.each { |code, message|
         err_name = message.gsub(/[ \-]/, '')
         const_set("RC_#{err_name.upcase}", code)
         err_class = Class.new(code < 400 ? Success : ClientError)
         err_class.instance_variable_set(:@code, code)
         const_set(err_name, err_class)
         CodeToError[code] = err_class
       }
     end

   Every name and value is known when the program is compiled. The loop is
   run here by the compile-time evaluator (ct_eval.c), and what it does
   becomes the body's own statements, in place of the loop:

     RC_OK = 200; class OK < Success; @code = 200; end; CodeToError[200] = OK; ...;
     StatusMessage

   (Hash#each answers its receiver). The classes it names are ordinary class
   nodes, so the registration that follows makes them as it makes a written
   class: nothing of the loop is left for the generated program to run.

   The loop runs here only when nothing else can make it answer otherwise.
   Each condition is one question below. Today each question is answered by
   a scan of the node table, before classes are registered; these scans are
   the answers ahead of the load-phase elaborator (#9898), which will answer
   the same questions from the definitions it has recorded, in load order:

     ct_table_only_read        the table's constant is written once and only
                               read, by calls that leave it as it is
     ct_const_given_elsewhere  a constant the loop sets is given a value
                               anywhere else in the program
     ct_core_method_changed    the program changes a core method the loop ran
     ct_method_defined         the program defines a method of a name that
                               runs whatever the receiver (the inherited and
                               const_added hooks, const_set,
                               instance_variable_set)

   The loop must be a statement of a class or module body, `H.each` or
   `H.each_pair` with a block of two parameters, H a constant the body
   assigned a Hash literal of literal keys and values earlier. A class it
   makes must be named by a const_set before anything else uses it, and gets
   instance variables only before then. A String it writes out is a frozen
   literal's (the table's under the frozen-string-literal pragma), written
   as that literal, or one the loop made, written as a new unfrozen String;
   an object the loop made (such a String, an Array) is written at one place
   only, since each place's node is a new object (ct_objects_written_once).
   Anything else leaves the loop as written.

   Until the inline load model goes (#9898's last part), its text expansion
   (sp_const_loop.c) runs these loops before the parse, and this desugar runs
   on graph tables only (ct_loops_in_analysis). */
#include <stdlib.h>
#include <string.h>

#include "analyze_internal.h"
#include "builtin_names.h"
#include "ct_eval.h"

/* two names, either of which may be missing (NULL), are the same */
static int ct_eq(const char *a, const char *b) { return a && b && sp_streq(a, b); }

/* The inline/graph coexistence switch: the inline model's text pass
   expands the loops, so this desugar runs only on a graph table (its root
   carries load_file), and under SPINEL_TABLE_LOOPS=analysis, where the
   inline model leaves its loops to it (a test-only switch, to compare the
   two). Deleted with the inline model. */
static int ct_loops_in_analysis(const NodeTable *nt) {
  const char *sw = getenv("SPINEL_TABLE_LOOPS");
  return nt_int(nt, nt->root_id, "load_file", -1) >= 0 || ct_eq(sw, "analysis");
}

/* ---- the questions ---- */

/* the spelling of constant path node `p` ("A::B"), rooted when it starts
   with `::`; 0 for a path whose head is an expression */
static int ct_path_text(const NodeTable *nt, int p, char *buf, size_t cap, int *rooted) {
  NodeKind k = p >= 0 ? nt_kind(nt, p) : NK_UnsupportedNode;
  const char *nm = nt_str(nt, p, "name");
  if (!nm || (k != NK_ConstantReadNode && k != NK_ConstantPathNode)) return 0;
  buf[0] = '\0';
  if (k == NK_ConstantPathNode) {
    int par = nt_ref(nt, p, "parent");
    if (par < 0) *rooted = 1;
    else if (!ct_path_text(nt, par, buf, cap, rooted)) return 0;
    if (par >= 0 && strlen(buf) + 2 < cap) strcat(buf, "::");
  }
  if (strlen(buf) + strlen(nm) + 1 > cap) return 0;
  strcat(buf, nm);
  return 1;
}

/* the modules `node` stands in, lexically ("A::B", "" at the top level);
   0 where one is a singleton class or a path that can't be spelled */
static int ct_lexical_path(const NodeTable *nt, const int *parent, int node, char *buf, size_t cap) {
  buf[0] = '\0';
  for (int a = parent[node]; a >= 0; a = parent[a]) {
    NodeKind k = nt_kind(nt, a);
    if (k == NK_SingletonClassNode) return 0;
    if (k != NK_ClassNode && k != NK_ModuleNode) continue;
    char seg[512]; int rooted = 0;
    if (!ct_path_text(nt, nt_ref(nt, a, "constant_path"), seg, sizeof seg, &rooted)) return 0;
    if (strlen(seg) + strlen(buf) + 3 > cap) return 0;
    char t[1024];
    snprintf(t, sizeof t, "%s%s%s", seg, buf[0] ? "::" : "", buf);
    strcpy(buf, t);
    if (rooted) break;
  }
  return 1;
}

/* is `node` inside the subtree of `top` */
static int ct_within(const int *parent, int node, int top) {
  for (; node >= 0; node = parent[node]) if (node == top) return 1;
  return 0;
}

/* a literal Symbol or String argument's text, or NULL */
static const char *ct_lit_name(const NodeTable *nt, int arg) {
  NodeKind k = nt_kind(nt, arg);
  return k == NK_SymbolNode ? nt_str(nt, arg, "value") : k == NK_StringNode ? nt_str(nt, arg, "content") : NULL;
}

/* the last name of a constant's full path */
static const char *ct_leaf(const char *full) {
  const char *l = strrchr(full, ':');
  return l ? l + 1 : full;
}

/* Does a definition at `at`, spelled `path` (the constant path node, or -1
   with `leaf` for a plain name written in the body), give the constant
   `full` a value? A plain name or a rooted path names one constant; a
   relative path's head is looked up when it runs, so any constant of its
   last name counts. */
static int ct_defines(const NodeTable *nt, const int *parent, int at, int path, const char *leaf, const char *full) {
  char outer[1024], seg[512], t[1600];
  int rooted = 0;
  if (path >= 0) {
    if (!ct_path_text(nt, path, seg, sizeof seg, &rooted)) return 1;
    if (rooted) return ct_eq(seg, full);
    if (strstr(seg, "::")) return ct_eq(nt_str(nt, path, "name"), ct_leaf(full));
    leaf = seg;
  }
  if (!ct_lexical_path(nt, parent, at, outer, sizeof outer)) return 1;
  snprintf(t, sizeof t, "%s%s%s", outer, outer[0] ? "::" : "", leaf);
  return ct_eq(t, full);
}

/* Is one of the constants `full[0..n)` ("M::Name") given a value anywhere
   in the program outside the loop `loop`: a class or module of that name, a
   write or a multiple assignment's target, or a const_set naming it, or
   naming a constant the scan can't spell? A const_set then replaces the
   value (with CRuby's warning) where a class definition would reopen it.
   One walk of the table for all of them. */
static int ct_const_given_elsewhere(const NodeTable *nt, const int *parent, char *const *full, int n, int loop) {
  for (int id = 0; id < nt->count; id++) {
    NodeKind k = nt_kind(nt, id);
    const char *leaf = NULL;
    int path = -1;   /* the definition's path node, -1 for a plain name */
    switch (k) {
    case NK_ClassNode: case NK_ModuleNode:
      path = nt_ref(nt, id, "constant_path"); leaf = nt_str(nt, path, "name");
      break;
    case NK_ConstantWriteNode: case NK_ConstantOrWriteNode: case NK_ConstantAndWriteNode:
    case NK_ConstantOperatorWriteNode: case NK_ConstantTargetNode:
      leaf = nt_str(nt, id, "name");
      break;
    case NK_ConstantPathWriteNode: case NK_ConstantPathOrWriteNode: case NK_ConstantPathAndWriteNode:
    case NK_ConstantPathOperatorWriteNode:
      path = nt_ref(nt, id, "target"); leaf = nt_str(nt, path, "name");
      break;
    case NK_ConstantPathTargetNode:
      path = id; leaf = nt_str(nt, id, "name");
      break;
    case NK_CallNode: {
      if (!nt_str(nt, id, "name") || !is_const_set_name(nt_str(nt, id, "name")) || ct_within(parent, id, loop)) break;
      int an = 0, args = nt_ref(nt, id, "arguments"), rv = nt_ref(nt, id, "receiver");
      const int *av = args >= 0 ? nt_arr(nt, args, "arguments", &an) : NULL;
      leaf = an ? ct_lit_name(nt, av[0]) : NULL;
      if (!leaf) return 1;
      /* on another receiver: any constant of that name */
      if (rv >= 0 && nt_kind(nt, rv) != NK_SelfNode)
        for (int i = 0; i < n; i++) if (ct_eq(ct_leaf(full[i]), leaf)) return 1;
      break;
    }
    default: break;
    }
    if (!leaf) continue;
    for (int i = 0; i < n; i++)
      if (ct_eq(ct_leaf(full[i]), leaf) && ct_defines(nt, parent, id, path, leaf, full[i])) return 1;
  }
  return 0;
}

/* `n` names one of the classes and modules `anc` lists (CRuby's ancestors
   of a core class, space-separated, as core_class_ancestors gives them): a
   constant read or a path whose last name is one of them */
static int ct_names_one(const NodeTable *nt, int n, const char *anc) {
  NodeKind k = n >= 0 ? nt_kind(nt, n) : NK_UnsupportedNode;
  const char *nm = nt_str(nt, n, "name");
  if ((k != NK_ConstantReadNode && k != NK_ConstantPathNode) || !nm) return 0;
  size_t l = strlen(nm);
  for (const char *p = anc; p && *p; ) {
    const char *e = strchr(p, ' ');
    size_t pl = e ? (size_t)(e - p) : strlen(p);
    if (pl == l && !strncmp(p, nm, l)) return 1;
    p = e ? e + 1 : p + pl;
  }
  return 0;
}

/* the class, module or singleton class whose body `node` is in, or -1 at
   the top level */
static int ct_owner(const NodeTable *nt, const int *parent, int node) {
  for (int a = parent[node]; a >= 0; a = parent[a]) {
    NodeKind k = nt_kind(nt, a);
    if (k == NK_ClassNode || k == NK_ModuleNode || k == NK_SingletonClassNode) return a;
  }
  return -1;
}

/* is owner `o` (ct_owner) one of `names` (ct_names_one): a class or module
   of that name, the singleton class of one, or the top level (Object,
   always among them) */
static int ct_owned_by(const NodeTable *nt, int o, const char *names) {
  if (o < 0) return 1;
  int p = nt_ref(nt, o, nt_kind(nt, o) == NK_SingletonClassNode ? "expression" : "constant_path");
  return ct_names_one(nt, p, names);
}

/* Does definer call `call` give or take a method `meth`: 1 when one of the
   names it spells is `meth` or one is not spelled (a variable). A send of a
   literal name (`send(:define_method, :inherited)`) is read as the call it
   names; a send whose target is computed reaches only the program's own
   methods, and like any call that names no method answers 0. */
static int ct_call_names(const NodeTable *nt, int call, const char *meth) {
  const char *namer = nt_str(nt, call, "name");
  int an = 0, args = nt_ref(nt, call, "arguments"), from = 0;
  const int *av = args >= 0 ? nt_arr(nt, args, "arguments", &an) : NULL;
  if (namer && is_send_family(namer)) { namer = an ? ct_lit_name(nt, av[0]) : NULL; from = 1; }
  if (!namer || !is_method_naming_call(namer)) return 0;
  if (an <= from) return 1;
  for (int i = from; i < an; i++) {
    NodeKind k = nt_kind(nt, av[i]);
    if (k == NK_TrueNode || k == NK_FalseNode) continue;   /* attr's writer flag names no method */
    const char *lit = ct_lit_name(nt, av[i]);
    if (!lit || ct_eq(lit, meth)) return 1;
    if (!is_method_list_call(namer)) break;   /* define_method / alias_method: the first names the method */
  }
  return 0;
}

/* Does the program change one of the core methods `ran[0..n)` (cls#meth) as
   instances of cls see it: a def, alias or definer call of that name in cls
   or one of its ancestors (a reopening, its singleton class, or the top
   level for Object), a mixin, class_eval, send or other change in one of
   them that the scan can't name, a refinement of one, or such a change
   through a receiver that may hold one of them (a variable)? The ancestors
   are CRuby's (core_class_ancestors); a class that table does not hold
   counts as changed. One walk of the table for all of them. */
static int ct_core_method_changed(const NodeTable *nt, const int *parent, const CtRan *ran, int n) {
  for (int i = 0; i < n; i++) if (!core_class_ancestors(ran[i].cls)) return 1;
  for (int id = 0; id < nt->count; id++) {
    NodeKind k = nt_kind(nt, id);
    const char *nm = nt_str(nt, id, "name");
    if (k == NK_DefNode || k == NK_AliasMethodNode) {
      const char *dn = k == NK_DefNode ? nm : nt_str(nt, nt_ref(nt, id, "new_name"), "value");
      int r = k == NK_DefNode ? nt_ref(nt, id, "receiver") : -1;
      for (int i = 0; i < n; i++) {
        const char *names = core_class_ancestors(ran[i].cls);
        if (!ct_eq(dn, ran[i].meth)) continue;
        if (r >= 0 && nt_kind(nt, r) != NK_SelfNode ? ct_names_one(nt, r, names)
                                                     : ct_owned_by(nt, ct_owner(nt, parent, id), names)) return 1;
      }
    }
    else if (k == NK_SingletonClassNode) {
      for (int i = 0; i < n; i++) if (ct_names_one(nt, nt_ref(nt, id, "expression"), core_class_ancestors(ran[i].cls))) return 1;
    }
    else if (k == NK_CallNode) {
      int r = nt_ref(nt, id, "receiver");
      int self_recv = r < 0 || nt_kind(nt, r) == NK_SelfNode;
      int naming = is_method_naming_call(nm), change = is_core_change_call(nm);
      if (is_refine_name(nm)) {
        int an = 0, args = nt_ref(nt, id, "arguments");
        const int *av = args >= 0 ? nt_arr(nt, args, "arguments", &an) : NULL;
        for (int i = 0; i < n && an; i++) if (ct_names_one(nt, av[0], core_class_ancestors(ran[i].cls))) return 1;
        continue;
      }
      if (!naming && !change) continue;
      int mine = 0;
      for (int i = 0; i < n; i++) {
        const char *names = core_class_ancestors(ran[i].cls);
        if (!(self_recv ? ct_owned_by(nt, ct_owner(nt, parent, id), names) : ct_names_one(nt, r, names))) continue;
        mine = 1;
        if (naming ? ct_call_names(nt, id, ran[i].meth) : 1) return 1;
      }
      /* a class held in a variable may be one of them: a send counts when
         it names a changing method; one named at run time reaches only the
         methods the program defines */
      if (!mine && !self_recv && nt_kind(nt, r) != NK_ConstantReadNode && nt_kind(nt, r) != NK_ConstantPathNode &&
          !(nt_kind(nt, r) == NK_CallNode && is_new_name(nt_str(nt, r, "name")))) {
        const char *sent = nm;
        if (nm && is_send_family(nm)) {
          int an = 0, args = nt_ref(nt, id, "arguments");
          const int *av = args >= 0 ? nt_arr(nt, args, "arguments", &an) : NULL;
          sent = an ? ct_lit_name(nt, av[0]) : NULL;
        }
        if (sent && is_core_change_call(sent) && !is_send_family(sent)) return 1;
      }
    }
  }
  return 0;
}

/* Does the program define a method `meth` anywhere, on any receiver: a def,
   an alias, or a definer call that names it or names a method the scan
   can't read (ct_call_names), directly or through a send. Asked of the methods
   that run whatever class the receiver is: a hook CRuby calls (inherited,
   const_added) or a method a module of the program may override for itself
   (const_set, instance_variable_set). */
int ct_method_defined(const NodeTable *nt, const char *meth) {
  for (int id = 0; id < nt->count; id++) {
    NodeKind k = nt_kind(nt, id);
    if (k == NK_DefNode && ct_eq(nt_str(nt, id, "name"), meth)) return 1;
    if (k == NK_AliasMethodNode && ct_eq(nt_str(nt, nt_ref(nt, id, "new_name"), "value"), meth)) return 1;
    if (k == NK_CallNode && ct_call_names(nt, id, meth)) return 1;
  }
  return 0;
}

/* Is the constant `name` (the loop's table) written once, and named
   elsewhere only as the receiver of a call that reads the Hash and leaves it
   as it is (the loop's own each; not another each, freeze or to_h, which
   answer the Hash itself) or as the head of a path? A class or module of
   that name, its singleton class, a def on it, a refinement or any other
   use hands it on, and a path write or multiple assignment of that name
   writes it again. */
static int ct_table_only_read(const NodeTable *nt, const int *parent, const char *name, int loop) {
  int writes = 0;
  for (int id = 0; id < nt->count; id++) {
    NodeKind k = nt_kind(nt, id);
    switch (k) {
    case NK_ConstantWriteNode: case NK_ConstantOrWriteNode: case NK_ConstantAndWriteNode:
    case NK_ConstantOperatorWriteNode:
      if (ct_eq(nt_str(nt, id, "name"), name)) writes++;
      break;
    case NK_ConstantTargetNode: case NK_ConstantPathTargetNode:
      if (ct_eq(nt_str(nt, id, "name"), name)) return 0;
      break;
    case NK_ConstantPathWriteNode: case NK_ConstantPathOrWriteNode: case NK_ConstantPathAndWriteNode:
    case NK_ConstantPathOperatorWriteNode:
      if (ct_eq(nt_str(nt, nt_ref(nt, id, "target"), "name"), name)) return 0;
      break;
    case NK_ConstantReadNode: case NK_ConstantPathNode: {
      if (!ct_eq(nt_str(nt, id, "name"), name)) break;
      int p = parent[id];
      if (p >= 0 && nt_kind(nt, p) == NK_ConstantPathNode && nt_ref(nt, p, "parent") == id) break;
      if (p < 0 || nt_kind(nt, p) != NK_CallNode || nt_ref(nt, p, "receiver") != id) return 0;
      const char *m = nt_str(nt, p, "name");
      if (!is_hash_read_only(m) || (p != loop && is_hash_self_answer(m))) return 0;
      break;
    }
    default: break;
    }
  }
  return writes == 1;
}

/* ---- the loop ---- */

/* the Hash literal `h` as the table's keys and values: every one a literal
   the evaluator reads, no repeated key */
static int ct_table(const NodeTable *nt, CtEnv *e, int h, Mv **keys, Mv **vals, int *n) {
  if (nt_kind(nt, h) != NK_HashNode) return 0;
  int en = 0;
  const int *el = nt_arr(nt, h, "elements", &en);
  *n = en;
  *keys = calloc((size_t)en + 1, sizeof(Mv)); *vals = calloc((size_t)en + 1, sizeof(Mv));
  if (!*keys || !*vals) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  int ok = 1;
  for (int i = 0; i < en && ok; i++) {
    CtVal kv, vv;
    ok = nt_kind(nt, el[i]) == NK_AssocNode && ct_eval(nt, e, nt_ref(nt, el[i], "key"), &kv) && kv.k == CT_VALUE &&
         ct_eval(nt, e, nt_ref(nt, el[i], "value"), &vv) && vv.k == CT_VALUE &&
         kv.mv.k != MV_ARR && vv.mv.k != MV_ARR;
    if (ok) { (*keys)[i] = kv.mv; (*vals)[i] = vv.mv; }
    for (int j = 0; j < i && ok; j++) if (mv_eq((*keys)[i], (*keys)[j])) ok = 0;   /* a repeated key */
  }
  return ok;
}

/* can v be written back as a node, with the classes named so far */
static int ct_spellable(const CtEnv *e, const int *named, CtVal v) {
  if (v.k == CT_CONST) return 1;
  if (v.k == CT_CLASS) return named[v.cls];
  switch (v.mv.k) {
  case MV_UNDEF: return 0;
  /* a frozen literal's String is the literal of its bytes, and one the loop
     made is a new unfrozen String: a node spells either. Not a table's
     unfrozen element, nor a String the loop made and froze */
  case MV_STR: return v.mv.lit == v.mv.frozen;
  case MV_ARR:
    for (int i = 0; i < v.mv.n; i++) {
      CtVal x; memset(&x, 0, sizeof x); x.mv = v.mv.a[i];
      if (!ct_spellable(e, named, x)) return 0;
    }
    return 1;
  default: return 1;
  }
}

/* the identities of the objects the loop made that value v holds (a String
   or an Array: a node spells each as a new object) onto *ids */
static void ct_made_objects(Mv v, const void ***ids, int *n, int *cap) {
  const void *id = v.k == MV_STR && !v.lit ? (const void *)v.s : v.k == MV_ARR ? (const void *)v.a : NULL;
  if (!id) return;
  if (*n == *cap) {
    *cap = *cap ? *cap * 2 : 16;
    *ids = realloc(*ids, sizeof(void *) * (size_t)*cap);
    if (!*ids) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  }
  (*ids)[(*n)++] = id;
  for (int i = 0; v.k == MV_ARR && i < v.n; i++) ct_made_objects(v.a[i], ids, n, cap);
}

/* Is every object the loop made written at one place? Each place writes a
   new object, where CRuby's places would hold the one the loop made. */
static int ct_objects_written_once(const CtEnv *e) {
  const void **ids = NULL;
  int n = 0, cap = 0, ok = 1;
  for (int i = 0; i < e->nfx; i++) {
    const CtFx *f = &e->fx[i];
    if (f->k == CT_FX_INDEX_SET) ct_made_objects(f->key.mv, &ids, &n, &cap);
    if (f->k != CT_FX_CLASS_NEW && !f->names) ct_made_objects(f->val.mv, &ids, &n, &cap);
  }
  for (int i = 1; i < n && ok; i++)   /* by equality: a loop makes few objects */
    for (int j = 0; j < i && ok; j++) ok = ids[i] != ids[j];
  free(ids);
  return ok;
}

static int ct_node(NodeTable *nt, const char *type) {
  int id = nt_new_node(nt, type);
  if (id < 0) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  return id;
}

static int ct_const_read(NodeTable *nt, const char *name) {
  int id = ct_node(nt, "ConstantReadNode");
  nt_node_set_str(nt, id, "name", name);
  return id;
}

/* the node of a value ct_spellable accepts */
static int ct_value_node(NodeTable *nt, const CtEnv *e, CtVal v) {
  if (v.k == CT_CONST) return nt_clone_subtree(nt, v.node);
  if (v.k == CT_CLASS) return ct_const_read(nt, e->cls[v.cls].name);
  int id;
  switch (v.mv.k) {
  case MV_NIL: return ct_node(nt, "NilNode");
  case MV_TRUE: return ct_node(nt, "TrueNode");
  case MV_FALSE: return ct_node(nt, "FalseNode");
  case MV_INT: id = ct_node(nt, "IntegerNode"); nt_node_set_int(nt, id, "value", v.mv.i); return id;
  case MV_STR:
    id = ct_node(nt, "StringNode");
    nt_node_set_str(nt, id, "content", v.mv.s);
    if (v.mv.frozen) nt_node_set_int(nt, id, "fzl", 1);
    return id;
  case MV_SYM: id = ct_node(nt, "SymbolNode"); nt_node_set_str(nt, id, "value", v.mv.s); return id;
  default: {
    int *el = malloc(sizeof(int) * ((size_t)v.mv.n + 1));
    if (!el) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
    for (int i = 0; i < v.mv.n; i++) {
      CtVal x; memset(&x, 0, sizeof x); x.mv = v.mv.a[i];
      el[i] = ct_value_node(nt, e, x);
    }
    id = ct_node(nt, "ArrayNode");
    nt_node_set_arr(nt, id, "elements", el, v.mv.n);
    free(el);
    return id;
  }
  }
}

static void ct_push(int **v, int *n, int *cap, int id) {
  if (*n == *cap) {
    *cap = *cap ? *cap * 2 : 16;
    *v = realloc(*v, sizeof(int) * (size_t)*cap);
    if (!*v) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  }
  (*v)[(*n)++] = id;
}

/* Can the loop's effects be written as statements of the body of `outer`
   (its module path): each class named by its first const_set and given
   instance variables only before, every constant set once and given no
   value elsewhere, every value spellable when it is written? */
static int ct_effects_writable(const NodeTable *nt, const int *parent, const CtEnv *e, const char *outer, int loop) {
  int *named = calloc((size_t)e->ncls + 1, sizeof(int));
  char **full = calloc((size_t)e->nfx + 1, sizeof(char *));
  if (!named || !full) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  int ok = 1, nfull = 0;
  for (int i = 0; i < e->nfx && ok; i++) {
    const CtFx *f = &e->fx[i];
    if (f->k == CT_FX_IVAR_SET) ok = !named[f->cls] && ct_spellable(e, named, f->val);
    /* a String key the loop made is stored as a frozen copy if the receiver
       is a Hash (and as itself if not): which is not known here */
    else if (f->k == CT_FX_INDEX_SET)
      ok = ct_spellable(e, named, f->key) && !(f->key.mv.k == MV_STR && !f->key.mv.lit) && ct_spellable(e, named, f->val);
    else if (f->k == CT_FX_CONST_SET) {
      for (int j = 0; j < i && ok; j++) if (e->fx[j].k == CT_FX_CONST_SET && ct_eq(e->fx[j].name, f->name)) ok = 0;
      size_t len = strlen(outer) + strlen(f->name) + 3;
      full[nfull] = malloc(len);
      if (!full[nfull]) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
      snprintf(full[nfull++], len, "%s%s%s", outer, outer[0] ? "::" : "", f->name);
      if (ok && f->names) named[f->val.cls] = 1;
      else if (ok) ok = ct_spellable(e, named, f->val);
    }
  }
  for (int k = 0; k < e->ncls && ok; k++) ok = named[k];   /* a class left anonymous is a run-time value */
  if (ok) ok = ct_objects_written_once(e);
  if (ok) ok = !ct_const_given_elsewhere(nt, parent, full, nfull, loop);
  for (int i = 0; i < nfull; i++) free(full[i]);
  free(full); free(named);
  return ok;
}

/* the statements the effects stand for, appended to *out */
static void ct_effects_write(NodeTable *nt, const CtEnv *e, int **out, int *n, int *cap) {
  int **ivars = calloc((size_t)e->ncls + 1, sizeof(int *));
  int *niv = calloc((size_t)e->ncls + 1, sizeof(int)), *civ = calloc((size_t)e->ncls + 1, sizeof(int));
  if (!ivars || !niv || !civ) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  for (int i = 0; i < e->nfx; i++) {
    const CtFx *f = &e->fx[i];
    if (f->k == CT_FX_IVAR_SET) {
      int w = ct_node(nt, "InstanceVariableWriteNode");
      nt_node_set_str(nt, w, "name", f->name);
      nt_node_set_ref(nt, w, "value", ct_value_node(nt, e, f->val));
      ct_push(&ivars[f->cls], &niv[f->cls], &civ[f->cls], w);
    }
    else if (f->k == CT_FX_CONST_SET && f->names) {
      /* the class takes its name: its definition, with what was set on it */
      int cls = ct_node(nt, "ClassNode"), body = -1;
      if (niv[f->val.cls]) {
        body = ct_node(nt, "StatementsNode");
        nt_node_set_arr(nt, body, "body", ivars[f->val.cls], niv[f->val.cls]);
      }
      nt_node_set_ref(nt, cls, "constant_path", ct_const_read(nt, f->name));
      nt_node_set_ref(nt, cls, "superclass", nt_clone_subtree(nt, e->cls[f->val.cls].parent));
      nt_node_set_ref(nt, cls, "body", body);
      ct_push(out, n, cap, cls);
    }
    else if (f->k == CT_FX_CONST_SET) {
      int w = ct_node(nt, "ConstantWriteNode");
      nt_node_set_str(nt, w, "name", f->name);
      nt_node_set_ref(nt, w, "value", ct_value_node(nt, e, f->val));
      ct_push(out, n, cap, w);
    }
    else if (f->k == CT_FX_INDEX_SET) {
      int args = ct_node(nt, "ArgumentsNode"), kv[2];
      kv[0] = ct_value_node(nt, e, f->key);
      kv[1] = ct_value_node(nt, e, f->val);
      nt_node_set_arr(nt, args, "arguments", kv, 2);
      int call = ct_node(nt, "CallNode");
      nt_node_set_str(nt, call, "name", "[]=");
      nt_node_set_int(nt, call, "attr_write", 1);
      nt_node_set_ref(nt, call, "receiver", nt_clone_subtree(nt, f->recv.node));
      nt_node_set_ref(nt, call, "arguments", args);
      nt_node_set_ref(nt, call, "block", -1);
      ct_push(out, n, cap, call);
    }
  }
  for (int k = 0; k < e->ncls; k++) free(ivars[k]);
  free(ivars); free(niv); free(civ);
}

/* Run loop statement `st` = before[i] of a body, whose statements before
   it are before[0..i). On success its statements are appended to *out and 1
   is answered. *parent is the table's parent map, made here when a loop
   first gets past its shape (and again after an expansion grew the table). */
static int ct_try_loop(NodeTable *nt, int **parent, int *pcount, const int *before, int i,
                       int **out, int *n, int *cap) {
  int st = before[i];
  int recv = nt_ref(nt, st, "receiver"), blk = nt_ref(nt, st, "block");
  const char *meth = nt_str(nt, st, "name"), *tname = nt_str(nt, recv, "name");
  if (nt_kind(nt, st) != NK_CallNode || recv < 0 || nt_kind(nt, recv) != NK_ConstantReadNode ||
      nt_ref(nt, st, "arguments") >= 0 || blk < 0 || nt_kind(nt, blk) != NK_BlockNode || !meth || !tname || !is_each_or_pair(meth)) return 0;
  int bp = nt_ref(nt, blk, "parameters"), ps = bp >= 0 ? nt_ref(nt, bp, "parameters") : -1;
  int rn = 0, on = 0, pn = 0, kn = 0;
  const int *req = ps >= 0 ? nt_arr(nt, ps, "requireds", &rn) : NULL;
  if (ps >= 0) { nt_arr(nt, ps, "optionals", &on); nt_arr(nt, ps, "posts", &pn); nt_arr(nt, ps, "keywords", &kn); }
  if (!req || rn != 2 || on || pn || kn || nt_ref(nt, ps, "rest") >= 0 || nt_ref(nt, ps, "keyword_rest") >= 0 ||
      nt_ref(nt, ps, "block") >= 0 || nt_kind(nt, req[0]) != NK_RequiredParameterNode ||
      nt_kind(nt, req[1]) != NK_RequiredParameterNode) return 0;
  int body = nt_ref(nt, blk, "body");
  if (body >= 0 && nt_kind(nt, body) != NK_StatementsNode) return 0;
  /* the table: a write of it earlier in this body */
  int def = -1;
  for (int j = 0; j < i; j++)
    if (nt_kind(nt, before[j]) == NK_ConstantWriteNode && ct_eq(nt_str(nt, before[j], "name"), tname)) def = before[j];
  if (def < 0 || nt_kind(nt, nt_ref(nt, def, "value")) != NK_HashNode) return 0;
  if (!*parent || *pcount != nt->count) {
    free(*parent);
    *parent = an_parent_map(nt); *pcount = nt->count;
    if (!*parent) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  }
  /* the modules the body's constants go in: the class's own path */
  char outer[1024];
  if (!ct_lexical_path(nt, *parent, st, outer, sizeof outer) || !ct_table_only_read(nt, *parent, tname, st)) return 0;
  int hv = nt_ref(nt, def, "value"), en = 0;
  Mv *keys = NULL, *vals = NULL;
  CtEnv e; memset(&e, 0, sizeof e);
  int ok = ct_table(nt, &e, hv, &keys, &vals, &en);
  const int *el = nt_arr(nt, hv, "elements", &en);
  ct_env_ran(&e, "Hash", meth);
  for (int k = 0; k < en && ok; k++) {
    ct_env_new_call(&e);
    CtVal kv, vv;
    memset(&kv, 0, sizeof kv); memset(&vv, 0, sizeof vv);
    /* a String key is the frozen literal of its bytes (a Hash literal's are,
       pragma or not); a String value is the table's element */
    kv.mv = keys[k]; vv.mv = vals[k];
    if (kv.mv.k == MV_STR) kv.mv.frozen = kv.mv.lit = 1;
    if (vv.mv.k == MV_STR) vv.mv.lit = 1;
    ok = nt_str(nt, req[0], "name") && nt_str(nt, req[1], "name") &&
         ct_env_set(&e, nt_str(nt, req[0], "name"), kv) && ct_env_set(&e, nt_str(nt, req[1], "name"), vv) &&
         ct_exec(nt, &e, body);
  }
  /* nothing in the program may make what ran answer otherwise */
  if (ok) ok = !ct_core_method_changed(nt, *parent, e.ran, e.nran);
  int sets = 0, ivs = 0;
  for (int f = 0; f < e.nfx; f++) { sets |= e.fx[f].k == CT_FX_CONST_SET; ivs |= e.fx[f].k == CT_FX_IVAR_SET; }
  if (ok && e.ncls) ok = !ct_method_defined(nt, "inherited");   /* CRuby calls it while the class has no name */
  if (ok && sets) ok = !ct_method_defined(nt, "const_set") && !ct_method_defined(nt, "const_added");
  if (ok && ivs) ok = !ct_method_defined(nt, "instance_variable_set");
  if (ok) ok = ct_effects_writable(nt, *parent, &e, outer, st);
  if (ok) {
    int base = nt->count;
    ct_effects_write(nt, &e, out, n, cap);
    ct_push(out, n, cap, nt_clone_subtree(nt, recv));   /* Hash#each answers its receiver */
    /* the statements stand where the loop stood: its file and line */
    long long line = nt_int(nt, st, "node_line", -1), file = nt_int(nt, st, "node_file", -1), col = nt_int(nt, st, "node_col", -1);
    for (int id = base; id < nt->count && line >= 0; id++) {
      nt_node_set_int(nt, id, "node_line", line);
      if (file >= 0) nt_node_set_int(nt, id, "node_file", file);
      if (col >= 0) nt_node_set_int(nt, id, "node_col", col);
    }
    /* the loop leaves the program: no pass that walks the table by id may
       read its block's locals or Symbols as the program's */
    nt_subtree_blank(nt, st);
  }
  ct_env_free(&e);
  free(keys); free(vals);
  return ok;
}

/* Every class and module body's table loops run (above), in place. */
int desugar_table_loops(Compiler *c) {
  NodeTable *nt = (NodeTable *)c->nt;
  if (!ct_loops_in_analysis(nt)) return 0;
  int n0 = nt->count, changed = 0;
  int *parent = NULL, pcount = 0;
  for (int id = 0; id < n0; id++) {
    NodeKind k = nt_kind(nt, id);
    int body = k == NK_ClassNode || k == NK_ModuleNode ? nt_ref(nt, id, "body") : -1;
    if (body < 0 || nt_kind(nt, body) != NK_StatementsNode) continue;
    int bn = 0;
    const int *bb0 = nt_arr(nt, body, "body", &bn);
    int *bb = malloc(sizeof(int) * ((size_t)bn + 1));
    if (!bb) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
    if (bn) memcpy(bb, bb0, sizeof(int) * (size_t)bn);
    int *nb = NULL, nn = 0, ncap = 0, any = 0;
    for (int i = 0; i < bn; i++) {
      int st = bb[i];
      if (!ct_try_loop(nt, &parent, &pcount, bb, i, &nb, &nn, &ncap)) { ct_push(&nb, &nn, &ncap, st); continue; }
      /* the body as it now reads, the statements after the loop still to
         come: a later loop's questions find what this one defined in its
         place, under this class (its parent map is made again) */
      int done = nn;
      for (int j = i + 1; j < bn; j++) ct_push(&nb, &nn, &ncap, bb[j]);
      nt_node_set_arr(nt, body, "body", nb, nn);
      nn = done;
      any = 1;
    }
    if (any) { nt_node_set_arr(nt, body, "body", nb, nn); changed = 1; }
    free(nb); free(bb);
  }
  free(parent);
  if (changed) comp_grow_node_arrays(c);
  return changed;
}
