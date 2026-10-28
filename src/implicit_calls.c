/* implicit_calls.c -- the methods CRuby calls that the program does not name
   (see implicit_calls.h). */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "implicit_calls.h"
#include "analyze_internal.h"

int g_dump_implicit = 0;

/* ---- the calls of a node ---- */

static unsigned ic_role_side(unsigned role) {
  if (role == BCR_SELF) return IC_INST;
  if (role == BCR_CLASS) return IC_CLASS;
  return IC_INST | IC_CLASS;   /* a class object is a value: every callback on an argument or element applies to one */
}

typedef struct { IcCall *out; int max, n; } IcSink;

static void ic_push(IcSink *s, const char *name, int operand, unsigned side, unsigned role, int recv) {
  if (s->n < s->max) {
    s->out[s->n].name = name;
    s->out[s->n].operand = operand;
    s->out[s->n].side = (unsigned char)side;
    s->out[s->n].role = (unsigned char)role;
    s->out[s->n].recv = (unsigned char)recv;
  }
  s->n++;
}

/* The callbacks of the builtin `name`, as calls on node `operand`: one per
   (callback, role). -1 when the table does not cover the name. */
static int ic_builtin_callbacks(IcSink *s, const char *name, int operand, unsigned roles_wanted, int recv) {
  const BopCallback *cbs = NULL;
  int n = bop_name_callbacks(name, &cbs);
  for (int i = 0; i < n; i++)
    for (unsigned bit = 1; bit <= BCR_LOADED; bit <<= 1)
      if ((cbs[i].roles & bit) && (roles_wanted & bit)) ic_push(s, cbs[i].name, operand, ic_role_side(bit), bit, recv);
  return n;
}

int ic_node_calls(Compiler *c, int id, IcCall *out, int max) {
  const NodeTable *nt = c->nt;
  IcSink s = { out, max, 0 };
  NtImplied rows[16];
  int nr = nt_implied_calls(nt, id, rows, 16), cnt = nr;
  NtImplied *big = NULL;
  const NtImplied *row = rows;
  if (nr > 16) {   /* a `when` with many conditions */
    big = malloc(sizeof *big * (size_t)nr);
    if (!big) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
    nt_implied_calls(nt, id, big, nr);
    row = big;
  }
  for (int i = 0; i < cnt; i++) {
    ic_push(&s, row[i].name, row[i].operand, row[i].side, 0, 0);
    /* the implied call of a core name is a call of the builtin on its
       operand: the elements of that operand and the operand itself, when it
       is a program subclass of the core class, are handed to its callbacks */
    if (row[i].operand >= 0) ic_builtin_callbacks(&s, row[i].name, row[i].operand, BCR_ELEM | BCR_SELF, 1);
  }
  free(big);
  if (nt_kind(nt, id) == NK_CallNode) {
    const char *name = nt_str(nt, id, "name");
    if (name && bop_name_callbacks(name, NULL) < 0) return IC_ANY;
    if (name) ic_builtin_callbacks(&s, name, id, BCR_ALL, 0);
  }
  return s.n;
}

/* ---- may the operand hold an object of the program's ---- */

/* Does call node `id` run a method of the program's, so that no builtin of its
   name runs? Its receiver (or self, without one) is an object of a class that
   has the method, or a receiverless call names a def at the top level. The
   types decide, so only a typed run says yes. This is the call plan's question
   (a receiverless call's target); it is asked here from the set of top-level
   def names until C5 reads ic_entered_unseen, and moves to the plan with it. */
int ic_runs_program_method(Compiler *c, int id) {
  const NodeTable *nt = c->nt;
  const char *name = nt_str(nt, id, "name");
  if (!c->ic || !c->ic->typed || !name) return 0;
  int recv = nt_ref(nt, id, "receiver"), cls = -1;
  if (recv >= 0 && nt_kind(nt, recv) != NK_SelfNode) {
    TyKind rt = comp_ntype(c, recv);
    if (!ty_is_object(rt)) return 0;
    cls = ty_object_class(rt);
  }
  else {
    const Scope *sc = comp_scope_of(c, id);
    if (sc && sc->class_id >= 0 && !sc->is_cmethod) cls = sc->class_id;
  }
  /* a def of the program's at the top level answers a receiverless call anywhere */
  if (recv < 0 && anh_has(&c->ic->toplevel, name)) return 1;
  return cls >= 0 && comp_method_in_chain(c, cls, name, NULL) >= 0;
}

/* A value of a builtin type calls a method of its builtin class, never one of
   a program's class: unless the program reopened a builtin class with a method
   of that name (the name is not one only plain classes hold). */
static int ic_builtin_type(Compiler *c, TyKind t) {
  switch (t) {
  case TY_RANGE: case TY_FLOAT_RANGE: case TY_STR_RANGE: case TY_TIME: case TY_COMPLEX:
  case TY_RATIONAL: case TY_MATCHDATA: case TY_REGEX:
    return 1;
  default:
    return cr_ty_builtin_value(c, t);
  }
}

static int ic_builtin_only(Compiler *c, TyKind t, const char *name) {
  if (!c->ic || !anh_has(&c->ic->class_only, name)) return 0;
  if (t == TY_POLY) return 0;
  return ic_builtin_type(c, t);
}

/* A boxed value (an Integer that may outgrow a machine word under promote)
   that the class facts show holds no class of the program's is a builtin value
   too (cr_recv_builtin_value). */
static int ic_boxed_builtin(Compiler *c, int node, const char *name) {
  if (comp_ntype(c, node) != TY_POLY || !c->ic || !anh_has(&c->ic->class_only, name)) return 0;
  const ClsSet *cs = cls_fact_node(c, node);
  return cs && cs->n == 0;
}

static int ic_may_be_object(Compiler *c, int node, const char *name) {
  if (node < 0) return 1;
  return !ic_builtin_only(c, comp_ntype(c, node), name) && !ic_boxed_builtin(c, node, name);
}

/* Can the elements of the value of `node` be objects of the program's? A
   collection of builtin values cannot; anything not known to be one can. */
static int ic_type_holds(Compiler *c, TyKind t, const char *name, int depth) {
  if (depth > 4) return 1;
  if (ty_is_array(t)) {
    TyKind et = ty_array_elem(t);
    return ic_type_holds(c, et, name, depth + 1) || (!ic_builtin_type(c, et) && !ty_is_array(et) && !ty_is_hash(et));
  }
  if (ty_is_hash(t))
    return ic_type_holds(c, ty_hash_key(t), name, depth + 1) || ic_type_holds(c, ty_hash_val(t), name, depth + 1) ||
           (!ic_builtin_type(c, ty_hash_key(t)) && !ty_is_array(ty_hash_key(t)) && !ty_is_hash(ty_hash_key(t))) ||
           (!ic_builtin_type(c, ty_hash_val(t)) && !ty_is_array(ty_hash_val(t)) && !ty_is_hash(ty_hash_val(t)));
  if (t == TY_RANGE || t == TY_STR_RANGE || t == TY_FLOAT_RANGE) return 0;
  return !ic_builtin_only(c, t, name);
}

static int ic_may_hold_elems(Compiler *c, int node, const char *name) {
  if (node < 0) return 1;
  return ic_type_holds(c, comp_ntype(c, node), name, 0) && !ic_boxed_builtin(c, node, name);
}

/* the last statement's node of a block's body, -1 when it has none */
static int ic_block_value(const NodeTable *nt, int blk) {
  int body = nt_ref(nt, blk, "body"), n = 0;
  const int *stmts;
  if (body < 0) return -1;
  if (nt_kind(nt, body) != NK_StatementsNode) return body;
  stmts = nt_arr(nt, body, "body", &n);
  return n > 0 ? stmts[n - 1] : -1;
}

int ic_operand_may_hold(Compiler *c, const IcCall *k) {
  const NodeTable *nt = c->nt;
  if (!c->ic || !c->ic->typed) return 1;
  if (!k->role) return k->operand < 0 ? 1 : ic_may_be_object(c, k->operand, k->name);
  int call = k->operand;
  /* an implied call's builtin has the operand for its receiver and no arguments or block */
  int recv = k->recv ? call : nt_ref(nt, call, "receiver"), args = k->recv ? -1 : nt_ref(nt, call, "arguments"), an = 0;
  const int *av = args >= 0 ? nt_arr(nt, args, "arguments", &an) : NULL;
  int blk = k->recv ? -1 : nt_ref(nt, call, "block");
  switch (k->role) {
  case BCR_ARG:
  case BCR_CLASS:
    for (int i = 0; i < an; i++) if (ic_may_be_object(c, av[i], k->name)) return 1;
    return 0;
  case BCR_ELEM:
    if (recv < 0 || ic_may_hold_elems(c, recv, k->name)) return 1;
    for (int i = 0; i < an; i++) if (ic_may_hold_elems(c, av[i], k->name)) return 1;
    return 0;
  case BCR_BLOCK:
    if (blk < 0) return 0;
    if (nt_kind(nt, blk) != NK_BlockNode) return 1;
    return ic_may_be_object(c, ic_block_value(nt, blk), k->name);
  case BCR_SELF:
    return recv < 0 || ic_may_be_object(c, recv, k->name);
  default:
    return 1;   /* a port, an object the data builds, a name asked: they do not depend on a type */
  }
}

/* the text for --dump-implicit: the node and what it calls */
void ic_cause(Compiler *c, int node, const IcCall *k, char *buf, size_t n) {
  const NodeTable *nt = c->nt;
  if (!k->role) {
    snprintf(buf, n, "%s line %d: %s", nt_type(nt, node), (int)nt_int(nt, node, "node_line", 0), k->name);
    return;
  }
  const char *role = k->role == BCR_ARG ? "ARG" : k->role == BCR_ELEM ? "ELEM" : k->role == BCR_BLOCK ? "BLOCK" :
                     k->role == BCR_SELF ? "SELF" : k->role == BCR_CLASS ? "CLASS" : k->role == BCR_PORT ? "PORT" :
                     k->role == BCR_ASKED ? "ASKED" : "LOADED";
  snprintf(buf, n, "%s line %d: %s of %s", k->recv ? nt_type(nt, node) : "call", (int)nt_int(nt, node, "node_line", 0), k->name, role);
}

/* ---- what the reachability walk collects ---- */

static void ic_clear(struct IcState *st) {
  for (int i = 0; i < st->nmarks; i++) { free(st->marks[i].name); free(st->marks[i].cause); }
  free(st->marks);
  for (int i = 0; i < st->nlive; i++) { free(st->live[i].name); free(st->live[i].cause); }
  free(st->live);
  anh_free(&st->class_only);
  anh_free(&st->defined);
  anh_free(&st->toplevel);
  for (int i = 0; i < 2; i++) anh_free(&st->live_set[i]);
  memset(st, 0, sizeof *st);
}

void ic_free(Compiler *c) {
  if (!c->ic) return;
  ic_clear(c->ic);
  free(c->ic);
  c->ic = NULL;
}

void ic_begin(Compiler *c, int typed) {
  if (!c->ic) {
    c->ic = calloc(1, sizeof *c->ic);
    if (!c->ic) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  }
  ic_clear(c->ic);
  c->ic->typed = typed;
  for (int s = 0; s < c->nscopes; s++)
    if (c->scopes[s].name && !anh_has(&c->ic->defined, c->scopes[s].name)) anh_add(&c->ic->defined, c->scopes[s].name);
  for (int k = 0; k < c->nclasses; k++)
    for (int i = 0; i < c->classes[k].naliases; i++) {
      const char *an = c->classes[k].alias_new[i];
      if (an && !anh_has(&c->ic->defined, an)) anh_add(&c->ic->defined, an);
    }
  for (int s = 0; s < c->nscopes; s++)
    if (c->scopes[s].name && c->scopes[s].class_id < 0 && !c->scopes[s].is_cmethod && !anh_has(&c->ic->toplevel, c->scopes[s].name))
      anh_add(&c->ic->toplevel, c->scopes[s].name);
  if (typed) cr_class_only_names(c, &c->ic->class_only);
}

void ic_scope(Compiler *c, int scope) {
  if (c->ic) c->ic->scope = scope;
}

int ic_defined(const Compiler *c, const char *name) {
  return c->ic && anh_has(&c->ic->defined, name);
}

void ic_record(Compiler *c, const char *name, unsigned side, const char *cause) {
  struct IcState *st = c->ic;
  if (!st) return;
  if (st->nmarks >= st->capmarks) {
    st->capmarks = st->capmarks ? st->capmarks * 2 : 64;
    st->marks = realloc(st->marks, sizeof *st->marks * (size_t)st->capmarks);
    if (!st->marks) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  }
  IcMark *m = &st->marks[st->nmarks++];
  m->name = strdup(name);
  m->cause = strdup(cause);
  if (!m->name || !m->cause) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
  m->scope = st->scope;
  m->side = (unsigned char)side;
}

void ic_end(Compiler *c) {
  struct IcState *st = c->ic;
  if (!st) return;
  for (int i = 0; i < st->nmarks; i++) {
    const IcMark *m = &st->marks[i];
    if (m->scope < 0 || m->scope >= c->nscopes || !c->scopes[m->scope].reachable) continue;
    if (m->name[0] == '*') { st->any = 1; }
    for (int sd = 0; sd < 2; sd++) {
      if (!(m->side & (1u << sd))) continue;
      if (m->name[0] != '*' && anh_has(&st->live_set[sd], m->name)) continue;
      if (st->nlive >= st->caplive) {
        st->caplive = st->caplive ? st->caplive * 2 : 64;
        st->live = realloc(st->live, sizeof *st->live * (size_t)st->caplive);
        if (!st->live) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
      }
      IcLive *l = &st->live[st->nlive++];
      l->name = strdup(m->name);
      l->cause = strdup(m->cause);
      if (!l->name || !l->cause) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
      l->side = (unsigned char)(1u << sd);
      if (m->name[0] != '*') anh_add(&st->live_set[sd], l->name);
    }
  }
}

int ic_live(const Compiler *c, const char *name, unsigned side) {
  const struct IcState *st = c->ic;
  if (!st || !name) return 0;
  if (st->any && bop_callback_roles(name)) return 1;
  return ((side & IC_INST) && anh_has(&st->live_set[0], name)) || ((side & IC_CLASS) && anh_has(&st->live_set[1], name));
}

int ic_any_seen(const Compiler *c) {
  return c->ic && c->ic->any;
}

/* ---- --dump-implicit ---- */

static int ic_live_cmp(const void *a, const void *b) {
  const IcLive *x = a, *y = b;
  int r = strcmp(x->name, y->name);
  return r ? r : (int)x->side - (int)y->side;
}

void ic_dump(Compiler *c, FILE *out) {
  struct IcState *st = c->ic;
  if (!st) return;
  qsort(st->live, (size_t)st->nlive, sizeof *st->live, ic_live_cmp);
  for (int i = 0; i < st->nlive; i++) {
    const IcLive *l = &st->live[i];
    fprintf(out, "%s %s %s\n", l->name[0] == '*' ? "any" : "live", l->side == IC_INST ? "inst" : "class", l->cause);
  }
  for (int s = 0; s < c->nscopes; s++) {
    const Scope *sc = &c->scopes[s];
    if (!sc->name || !sc->reachable || sc->def_node < 0 || nt_int(c->nt, sc->def_node, "node_file", 0) != 0) continue;
    fprintf(out, "def %s%s%s line %d\n", sc->class_id >= 0 ? c->classes[sc->class_id].name : "", sc->class_id >= 0 ? (sc->is_cmethod ? "." : "#") : "",
            sc->name, (int)nt_int(c->nt, sc->def_node, "node_line", 0));
  }
}
