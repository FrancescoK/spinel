#include "node_table.h"

#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* ---- field append helpers ---- */

static const SpNode *node_at(const NodeTable *nt, int id);

/* An allocation that fails stops the compile, here as in the parser's walk
   below: a node left without its type, a field without its key or a table
   without the slot it was growing by is read later as if it were there. */
static void nt_oom(void) {
  fprintf(stderr, "spinel: out of memory\n");
  exit(1);
}

/* n bytes, never NULL (an empty array still gets a block). */
static void *nt_alloc(size_t n) {
  void *p = malloc(n ? n : 1);
  if (!p) nt_oom();
  return p;
}

static void ensure_cap(void **buf, int *cap, int need, size_t elem) {
  if (need <= *cap) return;
  if (*cap > INT_MAX / 2) nt_oom();
  int nc = *cap ? *cap * 2 : 4;
  if (nc < need) nc = need;
  void *grown = realloc(*buf, (size_t)nc * elem);
  if (!grown) nt_oom();
  *buf = grown;
  *cap = nc;
}

/* A copy of the n bytes at s, NUL-terminated. */
static char *dup_n(const char *s, size_t n) {
  char *p = nt_alloc(n + 1);
  memcpy(p, s, n);
  p[n] = '\0';
  return p;
}

static void node_set_type(SpNode *nd, const char *type, size_t len) {
  free(nd->type);
  nd->type = dup_n(type, len);
}

static void node_add_str(SpNode *nd, const char *key, size_t klen, char *val /*owned*/, size_t vlen) {
  ensure_cap((void **)&nd->s, &nd->cs, nd->ns + 1, sizeof(SpStrField));
  nd->s[nd->ns].key = dup_n(key, klen);
  nd->s[nd->ns].disc = SP_FIELD_DISC(key, klen);
  nd->s[nd->ns].val = val;
  nd->s[nd->ns].val_len = vlen;
  nd->ns++;
}

static void node_add_int(SpNode *nd, const char *key, size_t klen, long long v) {
  ensure_cap((void **)&nd->i, &nd->ci, nd->ni + 1, sizeof(SpIntField));
  nd->i[nd->ni].key = dup_n(key, klen);
  nd->i[nd->ni].disc = SP_FIELD_DISC(key, klen);
  nd->i[nd->ni].val = v;
  nd->ni++;
}

static void node_add_ref(SpNode *nd, const char *key, size_t klen, int ref) {
  ensure_cap((void **)&nd->r, &nd->cr, nd->nr + 1, sizeof(SpRefField));
  nd->r[nd->nr].key = dup_n(key, klen);
  nd->r[nd->nr].disc = SP_FIELD_DISC(key, klen);
  nd->r[nd->nr].ref = ref;
  nd->nr++;
}

static void node_add_arr(SpNode *nd, const char *key, size_t klen, int *ids, int n /*owned*/) {
  ensure_cap((void **)&nd->a, &nd->ca, nd->na + 1, sizeof(SpArrField));
  nd->a[nd->na].key = dup_n(key, klen);
  nd->a[nd->na].disc = SP_FIELD_DISC(key, klen);
  nd->a[nd->na].ids = ids;
  nd->a[nd->na].n = n;
  nd->na++;
}

/* ---- filling the table (the parser's walk) ---- */

NodeTable *nt_new_table(void) {
  NodeTable *nt = calloc(1, sizeof(NodeTable));
  if (!nt) nt_oom();
  return nt;
}

/* The node at `id`, the table first extended to it; the slots it grows by
   start empty. */
static SpNode *node_put(NodeTable *nt, int id) {
  if (id < 0) return NULL;
  if (id >= nt->node_cap) {
    int nc = nt->node_cap ? nt->node_cap : 256;
    while (nc <= id) {
      if (nc > INT_MAX / 2) nt_oom();
      nc *= 2;
    }
    SpNode *grown = realloc(nt->nodes, sizeof(SpNode) * (size_t)nc);
    if (!grown) nt_oom();
    memset(grown + nt->node_cap, 0, sizeof(SpNode) * (size_t)(nc - nt->node_cap));
    nt->nodes = grown;
    nt->node_cap = nc;
  }
  if (id >= nt->count) nt->count = id + 1;
  return &nt->nodes[id];
}

void nt_put_type(NodeTable *nt, int id, const char *type) {
  SpNode *nd = node_put(nt, id);
  if (nd) node_set_type(nd, type, strlen(type));
}
void nt_put_str(NodeTable *nt, int id, const char *key, const char *val, size_t len) {
  if (len == 16 && !memcmp(val, "__cext_extension", 16) && !strcmp(key, "name")) nt->has_cext_decls = 1;
  SpNode *nd = node_put(nt, id);
  if (nd) node_add_str(nd, key, strlen(key), dup_n(val, len), len);
}
void nt_put_int(NodeTable *nt, int id, const char *key, long long val) {
  SpNode *nd = node_put(nt, id);
  if (nd) node_add_int(nd, key, strlen(key), val);
}
void nt_put_ref(NodeTable *nt, int id, const char *key, int child) {
  SpNode *nd = node_put(nt, id);
  if (nd) node_add_ref(nd, key, strlen(key), child);
}
void nt_put_arr(NodeTable *nt, int id, const char *key, int *ids, int n) {
  SpNode *nd = node_put(nt, id);
  if (nd) node_add_arr(nd, key, strlen(key), ids, n);
  else free(ids);
}
void nt_put_content(NodeTable *nt, int id, const char *content) {
  SpNode *nd = node_put(nt, id);
  if (!nd) return;
  free(nd->content);
  nd->content = dup_n(content, strlen(content));
}
void nt_put_source_file(NodeTable *nt, const char *path) {
  free(nt->source_file);
  nt->source_file = dup_n(path, strlen(path));
}
void nt_put_file(NodeTable *nt, int fid, const char *path) {
  if (fid < 0) return;
  if (fid >= nt->nfiles) {
    char **grown = realloc(nt->files, sizeof(char *) * (size_t)(fid + 1));
    if (!grown) nt_oom();
    for (int k = nt->nfiles; k <= fid; k++) grown[k] = NULL;
    nt->files = grown;
    nt->nfiles = fid + 1;
  }
  free(nt->files[fid]);
  nt->files[fid] = dup_n(path, strlen(path));
}

/* ---- the text form (--dump-ast) ---- */

/* A string value on one line: the bytes that would end the record or the
   field (newline, space, NUL) and the escape character itself as %XX. */
static void dump_escaped(FILE *out, const char *s, size_t n) {
  for (size_t i = 0; i < n; i++) {
    unsigned char c = (unsigned char)s[i];
    if (c == '%' || c == '\n' || c == '\r' || c == '\t' || c == ' ' || c == 0) fprintf(out, "%%%02X", c);
    else fputc(c, out);
  }
}

void nt_dump(const NodeTable *nt, FILE *out) {
  fprintf(out, "ROOT %d\n", nt->root_id);
  if (nt->source_file) {
    fputs("SOURCE_FILE ", out);
    dump_escaped(out, nt->source_file, strlen(nt->source_file));
    fputc('\n', out);
  }
  for (int f = 0; f < nt->nfiles; f++) {
    if (!nt->files[f]) continue;
    fprintf(out, "FILE %d ", f);
    dump_escaped(out, nt->files[f], strlen(nt->files[f]));
    fputc('\n', out);
  }
  for (int id = 0; id < nt->count; id++) {
    const SpNode *nd = &nt->nodes[id];
    if (nd->type) fprintf(out, "N %d %s\n", id, nd->type);
    for (int j = 0; j < nd->ns; j++) {
      fprintf(out, "S %d %s ", id, nd->s[j].key);
      dump_escaped(out, nd->s[j].val, nd->s[j].val_len);
      fputc('\n', out);
    }
    for (int j = 0; j < nd->ni; j++) fprintf(out, "I %d %s %lld\n", id, nd->i[j].key, nd->i[j].val);
    if (nd->content) fprintf(out, "F %d value %s\n", id, nd->content);
    for (int j = 0; j < nd->nr; j++) fprintf(out, "R %d %s %d\n", id, nd->r[j].key, nd->r[j].ref);
    for (int j = 0; j < nd->na; j++) {
      fprintf(out, "A %d %s ", id, nd->a[j].key);
      for (int k = 0; k < nd->a[j].n; k++) fprintf(out, k ? ",%d" : "%d", nd->a[j].ids[k]);
      fputc('\n', out);
    }
  }
}

/* Collect the subtree node ids reachable from `id` via ref + array fields. */
static void nt_clone_collect(NodeTable *nt, int id, char *seen, int *list, int *n) {
  if (id < 0 || id >= nt->count || seen[id]) return;
  seen[id] = 1; list[(*n)++] = id;
  SpNode *nd = &nt->nodes[id];
  for (int j = 0; j < nd->nr; j++) nt_clone_collect(nt, nd->r[j].ref, seen, list, n);
  for (int j = 0; j < nd->na; j++)
    for (int k = 0; k < nd->a[j].n; k++) nt_clone_collect(nt, nd->a[j].ids[k], seen, list, n);
}

/* Deep-clone the subtree rooted at `root`, appending fresh nodes to the
   table and remapping internal child references. Refs/array elements that
   point outside the subtree are kept verbatim. Returns the new root id, or
   -1 for a root outside the table. Grows nt->count; callers must resize parallel per-node
   arrays (Compiler.ntype / .nscope) to match afterward. */
int nt_clone_subtree(NodeTable *nt, int root) {
  if (root < 0 || root >= nt->count) return -1;
  char *seen = calloc((size_t)nt->count, 1);
  if (!seen) nt_oom();
  int *list = nt_alloc(sizeof(int) * (size_t)nt->count);
  int sn = 0;
  nt_clone_collect(nt, root, seen, list, &sn);
  free(seen);
  int base = nt->count;
  int *map = nt_alloc(sizeof(int) * (size_t)base);
  for (int i = 0; i < base; i++) map[i] = -1;
  for (int i = 0; i < sn; i++) map[list[i]] = base + i;
  SpNode *grown = realloc(nt->nodes, sizeof(SpNode) * (size_t)(base + sn));
  if (!grown) nt_oom();
  nt->nodes = grown;
  memset(&nt->nodes[base], 0, sizeof(SpNode) * (size_t)sn);
  for (int i = 0; i < sn; i++) {
    SpNode *src = &nt->nodes[list[i]];
    SpNode *dst = &nt->nodes[base + i];
    if (src->type)    dst->type    = dup_n(src->type, strlen(src->type));
    if (src->content) dst->content = dup_n(src->content, strlen(src->content));
    dst->ns = dst->cs = src->ns;
    if (src->ns) { dst->s = nt_alloc(sizeof(SpStrField) * (size_t)src->ns);
      for (int j = 0; j < src->ns; j++) {
        dst->s[j].key = dup_n(src->s[j].key, strlen(src->s[j].key)); dst->s[j].disc = src->s[j].disc;
        dst->s[j].val_len = src->s[j].val_len;
        dst->s[j].val = dup_n(src->s[j].val, src->s[j].val_len);
      } }
    dst->ni = dst->ci = src->ni;
    if (src->ni) { dst->i = nt_alloc(sizeof(SpIntField) * (size_t)src->ni);
      for (int j = 0; j < src->ni; j++) { dst->i[j].key = dup_n(src->i[j].key, strlen(src->i[j].key)); dst->i[j].disc = src->i[j].disc; dst->i[j].val = src->i[j].val; } }
    dst->nr = dst->cr = src->nr;
    if (src->nr) { dst->r = nt_alloc(sizeof(SpRefField) * (size_t)src->nr);
      for (int j = 0; j < src->nr; j++) {
        dst->r[j].key = dup_n(src->r[j].key, strlen(src->r[j].key));
        dst->r[j].disc = src->r[j].disc;
        int rf = src->r[j].ref;
        dst->r[j].ref = (rf >= 0 && rf < base && map[rf] >= 0) ? map[rf] : rf;
      } }
    dst->na = dst->ca = src->na;
    if (src->na) { dst->a = nt_alloc(sizeof(SpArrField) * (size_t)src->na);
      for (int j = 0; j < src->na; j++) {
        dst->a[j].key = dup_n(src->a[j].key, strlen(src->a[j].key));
        dst->a[j].disc = src->a[j].disc;
        dst->a[j].n = src->a[j].n;
        dst->a[j].ids = nt_alloc(sizeof(int) * (size_t)src->a[j].n);
        for (int k = 0; k < src->a[j].n; k++) {
          int e = src->a[j].ids[k];
          dst->a[j].ids[k] = (e >= 0 && e < base && map[e] >= 0) ? map[e] : e;
        }
      } }
  }
  int newroot = map[root];
  nt->count = base + sn;
  nt->version++; nt->edits++; nt->clone_version++;
  nt->node_cap = nt->count;  /* realloc above sized the array exactly */
  free(list); free(map);
  return newroot;
}

/* ---- synthetic node construction ---- */

static void nki_retyped(const NodeTable *nt, int id, NodeKind was);

/* Retype an existing node in place. A desugar that rewrites one construct
   into another (a CallOperatorWriteNode into the writer CallNode Ruby means)
   has to keep the id: the parent's ref names it. */
void nt_node_set_type(NodeTable *nt, int id, const char *type) {
  if (id < 0 || id >= nt->count || !type) return;
  NodeKind was = nt_kind(nt, id);
  SpNode *nd = &nt->nodes[id];
  node_set_type(nd, type, strlen(type));
  nd->kind = 0;          /* the cached NodeKind is stale now */
  nt->version++; nt->edits++;
  nki_retyped(nt, id, was);
}
int nt_new_node(NodeTable *nt, const char *type) {
  if (nt->count >= nt->node_cap) {
    int nc = nt->node_cap ? nt->node_cap * 2 : 8;
    if (nc <= nt->count) nc = nt->count + 1;
    SpNode *grown = realloc(nt->nodes, sizeof(SpNode) * (size_t)nc);
    if (!grown) nt_oom();
    nt->nodes = grown;
    nt->node_cap = nc;
  }
  int id = nt->count++;
  nt->version++; nt->edits++;
  SpNode *nd = &nt->nodes[id];
  memset(nd, 0, sizeof(SpNode));
  if (type) node_set_type(nd, type, strlen(type));
  return id;
}
int nt_appended_only_local_reads(const NodeTable *nt, int from) {
  if (from < 0) return 0;
  for (int n = from; n < nt->count; n++)
    if (nt_kind(nt, n) != NK_LocalVariableReadNode) return 0;
  return 1;
}
int nt_new_local_read(NodeTable *nt, const char *name) {
  unsigned v = nt->version;
  int id = nt_new_node(nt, "LocalVariableReadNode");
  nt_node_set_str(nt, id, "name", name);
  nt->read_version += nt->version - v;
  return id;
}
NtStamp nt_stamp(const NodeTable *nt) {
  NtStamp s = { nt->version, nt->read_version, nt->rename_version };
  return s;
}
int nt_stamp_holds(const NodeTable *nt, NtStamp s, int renames) {
  unsigned counted = nt->read_version - s.reads;
  if (renames) counted += nt->rename_version - s.renames;
  return nt->version - s.version == counted;
}
int nt_new_int(NodeTable *nt, long long v) {
  int n = nt_new_node(nt, "IntegerNode");
  nt_node_set_int(nt, n, "value", v);
  return n;
}

/* Turn an existing node INTO a node of another type, dropping every field it
   carried. A desugar that rewrites one construct as another needs the result
   to BE the new node rather than a wrapper around it, because consumers
   pattern-match on the node type -- `p []` reads its argument's own kind to
   build the empty literal, and a wrapper hides it. The id is stable, so
   parents and the scope map keep pointing at the right place. */
void nt_node_reset(NodeTable *nt, int id, const char *type) {
  SpNode *nd = (SpNode *)node_at(nt, id);
  if (!nd) return;
  NodeKind was = nt_kind(nt, id);
  nt->version++; nt->edits++;
  free(nd->type); nd->type = NULL;
  free(nd->content); nd->content = NULL;
  for (int j = 0; j < nd->ns; j++) { free(nd->s[j].key); free(nd->s[j].val); }
  for (int j = 0; j < nd->ni; j++) free(nd->i[j].key);
  for (int j = 0; j < nd->nr; j++) free(nd->r[j].key);
  for (int j = 0; j < nd->na; j++) { free(nd->a[j].key); free(nd->a[j].ids); }
  nd->ns = nd->ni = nd->nr = nd->na = 0;
  nd->kind = 0;
  if (type) node_set_type(nd, type, strlen(type));
  nki_retyped(nt, id, was);
}

void nt_node_set_str(NodeTable *nt, int id, const char *key, const char *val) {
  SpNode *nd = (SpNode *)node_at(nt, id);
  if (!nd) return;
  nt->version++; nt->edits++;
  size_t klen = strlen(key), vlen = strlen(val);
  if (vlen == 16 && !strcmp(val, "__cext_extension") && !strcmp(key, "name")) nt->has_cext_decls = 1;
  for (int j = 0; j < nd->ns; j++)
    if (sp_streq(nd->s[j].key, key)) {
      free(nd->s[j].val); nd->s[j].val = dup_n(val, vlen); nd->s[j].val_len = vlen; return;
    }
  node_add_str(nd, key, klen, dup_n(val, vlen), vlen);
}

/* the replaced string is answered, not freed: a caller up the stack may hold
   the pointer nt_str answered for it (node_table.h) */
char *nt_node_swap_str(NodeTable *nt, int id, const char *key, const char *val) {
  SpNode *nd = (SpNode *)node_at(nt, id);
  if (!nd) return NULL;
  nt->version++;
  if (nt_kind(nt, id) == NK_CallNode && sp_streq(key, "name")) nt->rename_version++;
  size_t vlen = strlen(val);
  for (int j = 0; j < nd->ns; j++)
    if (sp_streq(nd->s[j].key, key)) {
      char *held = nd->s[j].val;
      nd->s[j].val = dup_n(val, vlen); nd->s[j].val_len = vlen;
      return held;
    }
  node_add_str(nd, key, strlen(key), dup_n(val, vlen), vlen);
  return NULL;
}

void nt_node_restore_str(NodeTable *nt, int id, const char *key, char *held) {
  SpNode *nd = (SpNode *)node_at(nt, id);
  if (!nd) { free(held); return; }
  nt->version++;
  if (nt_kind(nt, id) == NK_CallNode && sp_streq(key, "name")) nt->rename_version++;
  for (int j = 0; j < nd->ns; j++)
    if (sp_streq(nd->s[j].key, key)) {
      free(nd->s[j].val);
      if (held) { nd->s[j].val = held; nd->s[j].val_len = strlen(held); return; }
      /* the swap added the key: the node had none */
      free(nd->s[j].key);
      memmove(&nd->s[j], &nd->s[j + 1], (size_t)(nd->ns - j - 1) * sizeof nd->s[0]);
      nd->ns--;
      return;
    }
  if (held) node_add_str(nd, key, strlen(key), held, strlen(held));
}

void nt_node_set_int(NodeTable *nt, int id, const char *key, long long val) {
  SpNode *nd = (SpNode *)node_at(nt, id);
  if (!nd) return;
  for (int j = 0; j < nd->ni; j++)
    if (sp_streq(nd->i[j].key, key)) {
      if (nd->i[j].val != val) { nd->i[j].val = val; nt->edits++; }
      return;
    }
  nt->edits++;
  node_add_int(nd, key, strlen(key), val);
}

void nt_node_set_ref(NodeTable *nt, int id, const char *key, int child) {
  SpNode *nd = (SpNode *)node_at(nt, id);
  if (!nd) return;
  for (int j = 0; j < nd->nr; j++)
    if (sp_streq(nd->r[j].key, key)) {
      if (nd->r[j].ref != child) { nd->r[j].ref = child; nt->edits++; }
      return;
    }
  nt->edits++;
  node_add_ref(nd, key, strlen(key), child);
}

void nt_node_set_arr(NodeTable *nt, int id, const char *key, const int *ids, int n) {
  SpNode *nd = (SpNode *)node_at(nt, id);
  if (!nd) return;
  nt->edits++;
  int *copy = NULL;
  if (n > 0) {
    copy = nt_alloc(sizeof(int) * (size_t)n);
    memcpy(copy, ids, sizeof(int) * (size_t)n);
  }
  for (int j = 0; j < nd->na; j++)
    if (sp_streq(nd->a[j].key, key)) { free(nd->a[j].ids); nd->a[j].ids = copy; nd->a[j].n = n; return; }
  node_add_arr(nd, key, strlen(key), copy, n);
}

void nt_free(NodeTable *nt) {
  if (!nt) return;
  for (int k = 0; k < nt->count; k++) {
    SpNode *nd = &nt->nodes[k];
    free(nd->type);
    free(nd->content);
    for (int j = 0; j < nd->ns; j++) { free(nd->s[j].key); free(nd->s[j].val); }
    for (int j = 0; j < nd->ni; j++) free(nd->i[j].key);
    for (int j = 0; j < nd->nr; j++) free(nd->r[j].key);
    for (int j = 0; j < nd->na; j++) { free(nd->a[j].key); free(nd->a[j].ids); }
    free(nd->s); free(nd->i); free(nd->r); free(nd->a);
  }
  free(nt->nodes);
  free(nt->source_file);
  for (int k = 0; k < nt->nfiles; k++) free(nt->files[k]);
  free(nt->files);
  free(nt->file_defers);
  free(nt);
}

/* ---- accessors ---- */

void nt_put_file_defers(NodeTable *nt, int fid) {
  if (fid < 0) return;
  if (fid >= nt->nfile_defers) {
    unsigned char *grown = realloc(nt->file_defers, (size_t)fid + 1);
    if (!grown) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }
    for (int k = nt->nfile_defers; k <= fid; k++) grown[k] = 0;
    nt->file_defers = grown;
    nt->nfile_defers = fid + 1;
  }
  nt->file_defers[fid] = 1;
}
int nt_file_defers(const NodeTable *nt, int fid) {
  return nt && nt->file_defers && fid >= 0 && fid < nt->nfile_defers && nt->file_defers[fid];
}
const char *nt_file_path(const NodeTable *nt, int fid) {
  if (!nt || fid < 0 || fid >= nt->nfiles) return NULL;
  return nt->files[fid];
}

static const SpNode *node_at(const NodeTable *nt, int id) {
  if (id < 0 || id >= nt->count) return NULL;
  return &nt->nodes[id];
}

#ifdef SP_WORK_COUNT
unsigned long long g_nt_work = 0;
#endif
const char *nt_type(const NodeTable *nt, int id) {
  NT_WORK();
  const SpNode *nd = node_at(nt, id);
  return nd ? nd->type : NULL;
}

/* Sorted node-type names; index i corresponds to enum value (i + 1) because
   NK_NONE = 0 precedes the X-macro entries. The X-macro list is alphabetically
   sorted, so this array is sorted and bsearch-able. */
static const char *const sp_kind_names[] = {
#define X(n) #n,
  SP_NODE_KINDS(X)
#undef X
};

static int sp_kind_cmp(const void *a, const void *b) {
  return strcmp((const char *)a, *(const char *const *)b);
}

NodeKind nt_kind_resolve(const NodeTable *nt, int id) {
  SpNode *nd = (SpNode *)node_at(nt, id);
  if (!nd) return NK_NONE;
  if (nd->kind) return (NodeKind)(nd->kind - 1);  /* cached (stored as kind+1) */
  NodeKind k = NK_NONE;
  if (nd->type) {
    const char *const *hit = (const char *const *)bsearch(
        nd->type, sp_kind_names, sizeof sp_kind_names / sizeof sp_kind_names[0],
        sizeof sp_kind_names[0], sp_kind_cmp);
    if (hit) k = (NodeKind)((hit - sp_kind_names) + 1);
  }
  nd->kind = (int)k + 1;  /* cache; 0 stays "uncomputed" */
  return k;
}

/* Node ids grouped by kind (CSR), cached per node table. The analyze passes
   each scan the whole table filtering by node kind, dozens of times per fixpoint
   iteration; this lets a pass walk only the nodes of the kind it cares about.
   Ids within a kind are in ascending order (matching a forward `for id` scan).
   Rebuilt when the table pointer or count changes (desugar passes append nodes),
   or when a node is retyped in place into another kind (nki_retyped).
   nt_kind is O(1) (cached per node), so a rebuild is a single linear pass. */
static const NodeTable *nki_nt = NULL;
static int nki_ntc = -1;
static int *nki_ids = NULL;   /* all ids, grouped by kind */
static int *nki_off = NULL;   /* size NK__COUNT+1; kind k spans [off[k], off[k+1]) */
/* Id arrays superseded while an NT_FOREACH_KIND loop was open (its body
   appended nodes and something rebuilt the cache): kept until the last open
   iterator closes, since the loop is still reading its own. */
static int nki_live = 0;
static int **nki_retired = NULL;
static int nki_nretired = 0, nki_cretired = 0;
static void nki_retire(int *p) {
  if (!p) return;
  if (nki_nretired == nki_cretired) {
    int nc = nki_cretired ? nki_cretired * 2 : 8;
    int **np = (int **)realloc(nki_retired, (size_t)nc * sizeof(int *));
    if (!np) return;   /* kept alive by the leak rather than freed under a reader */
    nki_retired = np; nki_cretired = nc;
  }
  nki_retired[nki_nretired++] = p;
}
void nt_kind_iter_open(void) { nki_live++; }
void nt_kind_iter_close(NtKindIter *it) {
  (void)it;
  if (--nki_live > 0) return;
  for (int i = 0; i < nki_nretired; i++) free(nki_retired[i]);
  nki_nretired = 0;
}
/* Node id was retyped in place (nt_node_set_type, nt_node_reset) and is of
   another kind now. The index still lists it under the kind it had and not
   under its new one, and the node count, which is what tells a rebuild is
   due, did not change: a desugar that folds `RUBY_ENGINE == "spinel"` into
   a TrueNode appends nothing, so a later walk of the CallNodes was handed
   the TrueNode and read its absent name. Drop the index; the next ask
   rebuilds it, once however many nodes changed kind meanwhile. */
static void nki_retyped(const NodeTable *nt, int id, NodeKind was) {
  if (nki_nt == nt && nt_kind(nt, id) != was) nki_nt = NULL;
}
static void nki_build(const NodeTable *nt) {
  int n = nt->count;
  if (nki_live > 0) nki_retire(nki_ids); else free(nki_ids);
  free(nki_off);
  nki_off = (int *)calloc((size_t)NK__COUNT + 1, sizeof(int));
  if (!nki_off) nt_oom();
  nki_ids = nt_alloc((size_t)n * sizeof(int));
  nki_nt = nt; nki_ntc = n;
  for (int id = 0; id < n; id++) nki_off[(int)nt_kind(nt, id) + 1]++;
  for (int k = 1; k <= NK__COUNT; k++) nki_off[k] += nki_off[k - 1];
  /* nki_off[k] is now the start of kind k; fill, advancing a local cursor */
  int *cur = nt_alloc((size_t)NK__COUNT * sizeof(int));
  for (int k = 0; k < NK__COUNT; k++) cur[k] = nki_off[k];
  for (int id = 0; id < n; id++) { int k = (int)nt_kind(nt, id); nki_ids[cur[k]++] = id; }
  free(cur);
}
/* Return the ids of nodes of kind `k` (ascending), writing the count to *count.
   The returned pointer is valid until the next call with a changed node table. */
/* Exchange the contents of nodes a and b: what was node a is now numbered b,
   and the reverse. A desugar that must put a new node AHEAD of an existing
   one in node order (passes that fold by ascending id read it first) builds
   it at the end and swaps it into the earlier slot; the caller re-points the
   references to both. */
void nt_swap_nodes(NodeTable *nt, int a, int b) {
  if (a < 0 || b < 0 || a >= nt->count || b >= nt->count || a == b) return;
  SpNode t = nt->nodes[a];
  nt->nodes[a] = nt->nodes[b];
  nt->nodes[b] = t;
  nt->version++; nt->edits++;
  nki_nt = NULL;   /* the kind index lists ids by kind: rebuild it */
}

const int *nt_nodes_of_kind(const NodeTable *nt, NodeKind k, int *count) {
  if (nki_nt != nt || nki_ntc != nt->count) nki_build(nt);
  if (!nki_off || !nki_ids || k < 0 || k >= NK__COUNT) { *count = 0; return NULL; }
  *count = nki_off[k + 1] - nki_off[k];
  return nki_ids + nki_off[k];
}


int nt_set_str(NodeTable *nt, int id, const char *key, const char *val) {
  SpNode *nd = (SpNode *)node_at(nt, id);
  if (!nd) return 0;
  nt->version++; nt->edits++;
  size_t vlen = strlen(val);
  for (int j = 0; j < nd->ns; j++) {
    if (sp_streq(nd->s[j].key, key)) {
      free(nd->s[j].val);
      nd->s[j].val = dup_n(val, vlen);
      nd->s[j].val_len = vlen;
      return 1;
    }
  }
  return 0;
}





const char *nt_content(const NodeTable *nt, int id) {
  const SpNode *nd = node_at(nt, id);
  return nd ? nd->content : NULL;
}

int nt_num_refs(const NodeTable *nt, int id) {
  const SpNode *nd = node_at(nt, id);
  return nd ? nd->nr : 0;
}
int nt_ref_at(const NodeTable *nt, int id, int i) {
  const SpNode *nd = node_at(nt, id);
  if (!nd || i < 0 || i >= nd->nr) return -1;
  return nd->r[i].ref;
}
int nt_num_arrs(const NodeTable *nt, int id) {
  const SpNode *nd = node_at(nt, id);
  return nd ? nd->na : 0;
}
const int *nt_arr_at(const NodeTable *nt, int id, int i, int *out_n) {
  *out_n = 0;
  const SpNode *nd = node_at(nt, id);
  if (!nd || i < 0 || i >= nd->na) return NULL;
  *out_n = nd->a[i].n;
  return nd->a[i].ids;
}

int nt_call_args_plain(const NodeTable *nt, int id) {
  int args = nt_ref(nt, id, "arguments");
  if (args < 0) return 1;
  int argc = 0;
  const int *argv = nt_arr(nt, args, "arguments", &argc);
  return !nt_argv_has(nt, argv, argc, NT_ARG_SPLAT | NT_ARG_BLOCK);
}

/* Copy the subtree at `root` of `src` into `dst` (every field, children
   recursively); the new root's id in dst, or -1. A desugar parses a snippet
   into its own table and grafts the result into the program's. */
int nt_import_subtree(NodeTable *dst, const NodeTable *src, int root) {
  if (!dst || !src || root < 0 || root >= src->count) return -1;
  dst->has_cext_decls |= src->has_cext_decls;
  const SpNode *sn = &src->nodes[root];
  int id = nt_new_node(dst, sn->type ? sn->type : "");
  if (id < 0) return -1;
  if (sn->content) { SpNode *dn = &dst->nodes[id]; dn->content = dup_n(sn->content, strlen(sn->content)); }
  for (int j = 0; j < sn->ns; j++) {
    char *v = dup_n(sn->s[j].val, sn->s[j].val_len);
    node_add_str(&dst->nodes[id], sn->s[j].key, strlen(sn->s[j].key), v, sn->s[j].val_len);
  }
  for (int j = 0; j < sn->ni; j++) nt_node_set_int(dst, id, sn->i[j].key, sn->i[j].val);
  for (int j = 0; j < sn->nr; j++) {
    int ch = sn->r[j].ref >= 0 ? nt_import_subtree(dst, src, sn->r[j].ref) : -1;
    nt_node_set_ref(dst, id, sn->r[j].key, ch);
  }
  for (int j = 0; j < sn->na; j++) {
    int n = sn->a[j].n;
    int *ids = nt_alloc(sizeof(int) * (size_t)n);
    for (int q = 0; q < n; q++) ids[q] = sn->a[j].ids[q] >= 0 ? nt_import_subtree(dst, src, sn->a[j].ids[q]) : -1;
    nt_node_set_arr(dst, id, sn->a[j].key, ids, n);
    free(ids);
  }
  return id;
}
