/* analyze_cls.c -- the user classes a value can hold (#8530).

   One fact, decided once by the analysis before the type fixpoint, for
   every node and every slot: the set of user classes an object the value
   holds, or reaches through a container, a Proc or a method value, can be
   an instance of. A call on a boxed receiver can then bind and dispatch to
   the methods of the classes in the receiver's set instead of every class
   with the name: `[History.new, Empty.new][0].output` need not box
   Seq#output's parameters.

   The fact is a may-hold over-approximation computed without types, so it
   is the same whatever the fixpoint later decides: a Steensgaard-style
   unification. Every node and every slot (a local, a parameter, an ivar by
   class family and name, a global, a constant, a class variable, a method's
   value, a method's yield arguments and its blocks' values) is an element
   of a union-find; a flow unifies two elements (an assignment, a read, an
   argument with a parameter, a call with a method's value, a yield with a
   block parameter), and a constructor (`X.new`, `X.allocate`, a Struct's
   `X[...]`, `self` in an instance method, a rescue binding) adds classes
   to its element's set. A container is not told from its elements (the set
   of `[a, b]` is a's and b's; an element read or an iteration keeps the
   container's set), so a store through any name of the container grows
   every name's set, as a mutation through an alias needs. A builtin call
   the analysis does not model answers the union of its receiver, its
   arguments, its block's parameters and its block's value, which is also
   where any of them may end up stored.

   Where the analysis cannot see what reaches an element it holds every
   class (CF_ALL): a call named by a send, a method or a define_method, a
   value a Marshal, an ObjectSpace, a Fiber or a Thread hands out, a
   parameter of a method the runtime calls back (a protocol method: to_s,
   <=>, each, call, ...), a lambda's or a define_method block's parameter,
   a pattern's binding, a multiple assignment's target, a loop's value, a
   `new` on a class value.

   Rounds: the unifications a call makes depend on the receiver's set
   (which classes' methods it names), and that set grows as elements
   unify, so the node walk repeats until a round changes nothing. Each
   round only unifies and only adds classes, so it stops.

   Only the node facts are kept (c->cls_fact, read through cls_fact_node):
   a consumer asks about a call's receiver. Nodes made after the pass (a
   desugar's) have no fact and hold every class. */

#include "analyze_internal.h"
#include "builtin_names.h"

int class_has_exc_name(Compiler *c, int ci);   /* codegen.c */

#define CF_ALL   0      /* the pool index of the set of every class */
#define CF_EMPTY 1      /* ... and of no class */
#define CF_YARGS 8      /* yield positions a method's blocks are bound by */
#define CF_ROUNDS 64
#define CF_WHY_CAP (-1)

typedef struct { int cls; const char *name; int el; } CFEntry;
typedef struct { const char *name; int *mi; int n; int *cmi; int ncm; int *rd; int nrd; int *wr; int nwr; } CFByName;

typedef struct CF {
  Compiler *c; const NodeTable *nt; int *par; int nnodes;
  int nel, cel; int *uf; int *set;      /* union-find: parent, and the root's pool index */
  ClsSet *pool; int npool, cpool; int *ph; int phcap;
  int **lv_el; int *nlv;                /* per scope, per local index */
  int *ret_el, *yval_el, *self_el, **yarg_el;
  int *def_mi;                          /* DefNode -> scope */
  CFEntry *ent; int ent_cap, ent_n;     /* (key, name) slots */
  int *own, *desc, *fam;                /* per class: {k + its singleton classes}, its subtree, its family key */
  unsigned char *mod;                   /* per class: a module */
  unsigned char *has_super;             /* per scope: a super in it, which hands the block on */
  unsigned char *protocol;              /* per scope: the runtime may call it with its own arguments */
  const char **dyn; int ndyn, cdyn;     /* method names a send, a method(:m) or a define_method names */
  int dyn_all, all_ivars, has_mm;
  int exc_set;                          /* every user exception class */
  int fiber_ch;                         /* what a Fiber.yield answers: a resume's arguments */
  unsigned char *yval_used;             /* per scope: a yield's value is read (else the blocks' values go nowhere) */
  unsigned char *has_native;            /* per class: native bindings, made on first ask */
  CFByName *bn; int bn_cap, bn_n;
  int changed, round;
  int phase;              /* 0: only what the receivers' classes decide; 1: the builtin answers too */
  int *open; int nopen;   /* the runtime's classes and modules the program reopens (cf_open_self) */
  int *why;                   /* SPINEL_CLS_FACTS=why: per root, the rule (its source line) that made it
                                 every class, CF_WHY_CAP when a union outgrew CLS_SET_MAX */
  int *why_el;                /* ... and the element the rule named (a node: the call, the argument) */
  int *usz;                   /* ... per root, its element count */
  int (*uev)[3]; int nuev, cuev;  /* ... each union of two classes: the rule's line, the root, the smaller count */
  unsigned char *exec_esc;    /* per scope: its block parameter may run under another self */
  unsigned char *exec_blk;    /* per node: a block or lambda that may run under another self */
  int pending;            /* calls round 0 left to phase 1 */
  /* directed mode (#8837, SPINEL_CLS_FLOW): a flow is an edge from the
     element it reads to the element it writes, and a set reaches along the
     edges; no two elements are made one */
  int directed;
  int **succ; int *nsucc, *csucc;       /* per element: the elements it flows into */
  int *wl, nwl, cwl; unsigned char *inwl; int dcap;
  unsigned long long *eh; int ehcap, ehn;   /* the edges made, (src << 32 | dst) + 1 */
  /* the contents (directed mode): elements a flow connects share one
     contents class (a union-find over the elements), and a class's contents
     element, made on first use, holds what any container they hold holds.
     A contents element is in its own class, so a container's contents'
     contents are its contents (one level, as in Das's one-level flow). */
  int **psucc, *npsucc, *cpsucc;        /* per element: the elements its objects reach (a share) */
  int **pts, *npts, *cpts;              /* per element: the objects it may hold, sorted */
  int **pdel, *npdel, *cpdel;           /* per element: the objects added since it was last sent on */
  int **ld, *nld, *cld, **st, *nst, *cst;   /* per element: the loads out of it, the stores into it */
  unsigned char *ptop, *esc;            /* may hold an untracked container; its objects escaped */
  unsigned char *smc;                   /* a summary object's contents element: past the cap it gives up */
  int *elobj;                           /* per element: the object it stands for, -1 */
  int *summ;                            /* per element: the object that stands for all it holds past the cap, -1 */
  int *obj_cont, nobj, cobj;            /* per object: its contents element */
  int draining;
  int gsum;                             /* the one summary a summary's own contents join past the cap, -1 */
  long st_edges, st_pts, st_drain, st_rounds;
  int *fs, nfs, cfs;                   /* new edges whose source's objects are yet to be sent: (src, dst, kind) */
  int *orig;                  /* (directed, SPINEL_CLS_FLOW=why) per element, the rule line that made it every class */
  int dbg_seed, dbg_ptop;     /* SPINEL_CLS_FLOW_SEED, SPINEL_CLS_FLOW_PTOP: print where every class, and an untracked container, start */
  int pts_max;                /* objects an element holds before it joins the summary (CF_PTS_MAX; SPINEL_CLS_FLOW_PTSMAX overrides) */
} CF;

static void cf_oom(void) { fprintf(stderr, "spinel: out of memory\n"); exit(1); }

/* ---- the pool of sets ---- */

static int cf_set_cmp(const void *a, const void *b) { return *(const int *)a - *(const int *)b; }
static unsigned cf_set_hash(const ClsSet *s) {
  unsigned h = (2166136261u ^ (unsigned)s->all) * 16777619u ^ (unsigned)s->bv;
  for (int i = 0; i < s->n; i++) h = (h ^ (unsigned)s->cls[i]) * 16777619u;
  return h;
}
static int cf_set_eq(const ClsSet *a, const ClsSet *b) {
  if (a->all != b->all || a->n != b->n || a->bv != b->bv) return 0;
  for (int i = 0; i < a->n; i++) if (a->cls[i] != b->cls[i]) return 0;
  return 1;
}
/* the pool index of set s, normalized (sorted, no duplicate, every class
   past the cap) */
static int cf_pool(CF *f, ClsSet *s) {
  if (s->all) { s->n = 0; s->bv = 0; return CF_ALL; }
  if (s->n > 1) {
    qsort(s->cls, (size_t)s->n, sizeof s->cls[0], cf_set_cmp);
    int w = 0;
    for (int i = 0; i < s->n; i++) if (w == 0 || s->cls[w - 1] != s->cls[i]) s->cls[w++] = s->cls[i];
    s->n = (unsigned char)w;
  }
  if (s->n == 0 && !s->bv) return CF_EMPTY;
  if (f->npool * 2 >= f->phcap) {
    int ncap = f->phcap ? f->phcap * 2 : 1024;
    int *nh = malloc(sizeof *nh * (size_t)ncap);
    if (!nh) cf_oom();
    for (int i = 0; i < ncap; i++) nh[i] = -1;
    for (int i = 0; i < f->npool; i++) {
      unsigned j = cf_set_hash(&f->pool[i]) & (unsigned)(ncap - 1);
      while (nh[j] >= 0) j = (j + 1) & (unsigned)(ncap - 1);
      nh[j] = i;
    }
    free(f->ph); f->ph = nh; f->phcap = ncap;
  }
  unsigned j = cf_set_hash(s) & (unsigned)(f->phcap - 1);
  while (f->ph[j] >= 0) {
    if (cf_set_eq(&f->pool[f->ph[j]], s)) return f->ph[j];
    j = (j + 1) & (unsigned)(f->phcap - 1);
  }
  if (f->npool == f->cpool) {
    f->cpool = f->cpool ? f->cpool * 2 : 256;
    f->pool = realloc(f->pool, sizeof *f->pool * (size_t)f->cpool);
    if (!f->pool) cf_oom();
  }
  f->pool[f->npool] = *s;
  f->ph[j] = f->npool;
  return f->npool++;
}
static int cf_union(CF *f, int a, int b) {
  if (a == b || b == CF_EMPTY) return a;
  if (a == CF_EMPTY) return b;
  if (a == CF_ALL || b == CF_ALL) return CF_ALL;
  const ClsSet *x = &f->pool[a], *y = &f->pool[b];
  ClsSet s; memset(&s, 0, sizeof s);
  s.bv = (unsigned char)(x->bv | y->bv);
  if (x->n + y->n > CLS_SET_MAX) {
    /* the merge may still fit: count the distinct ones */
    int i = 0, j = 0, n = 0;
    while (i < x->n || j < y->n) {
      if (j >= y->n || (i < x->n && x->cls[i] < y->cls[j])) i++;
      else if (i >= x->n || y->cls[j] < x->cls[i]) j++;
      else { i++; j++; }
      n++;
    }
    if (n > CLS_SET_MAX) return CF_ALL;
  }
  /* a member of both is taken once: the count above found the merge fits */
  int i = 0, j = 0;
  while (i < x->n || j < y->n) {
    if (j >= y->n || (i < x->n && x->cls[i] < y->cls[j])) s.cls[s.n++] = x->cls[i++];
    else if (i >= x->n || y->cls[j] < x->cls[i]) s.cls[s.n++] = y->cls[j++];
    else { s.cls[s.n++] = x->cls[i]; i++; j++; }
  }
  return cf_pool(f, &s);
}
static int cf_single(CF *f, int cls) {
  ClsSet s; memset(&s, 0, sizeof s);
  s.cls[0] = cls; s.n = 1;
  return cf_pool(f, &s);
}
/* the set of a builtin value with no class of the program's */
static int cf_bv_set(CF *f) {
  ClsSet s; memset(&s, 0, sizeof s);
  s.bv = 1;
  return cf_pool(f, &s);
}
/* the Class object of k: a member past the classes */
static int cf_classval(CF *f, int k) { return cf_single(f, k + f->c->nclasses); }
/* the Class objects of the instance classes of set pidx */
static int cf_classvals_of(CF *f, int pidx) {
  if (pidx == CF_ALL) return CF_ALL;
  const ClsSet *x = &f->pool[pidx];
  ClsSet s; memset(&s, 0, sizeof s);
  for (int i = 0; i < x->n; i++) {
    if (x->cls[i] >= f->c->nclasses) continue;
    if (s.n >= CLS_SET_MAX) { s.all = 1; break; }
    s.cls[s.n++] = x->cls[i] + f->c->nclasses;
  }
  return cf_pool(f, &s);
}

/* ---- the union-find ---- */

static void cf_grow_directed(CF *f);
static int cf_new_el(CF *f) {
  if (f->nel == f->cel) {
    f->cel = f->cel ? f->cel * 2 : 1024;
    f->uf = realloc(f->uf, sizeof *f->uf * (size_t)f->cel);
    f->set = realloc(f->set, sizeof *f->set * (size_t)f->cel);
    if (!f->uf || !f->set) cf_oom();
    if (f->why && !(f->why = realloc(f->why, sizeof *f->why * (size_t)f->cel))) cf_oom();
    if (f->usz && !(f->usz = realloc(f->usz, sizeof *f->usz * (size_t)f->cel))) cf_oom();
    if (f->why_el && !(f->why_el = realloc(f->why_el, sizeof *f->why_el * (size_t)f->cel))) cf_oom();
  }
  if (f->directed && f->nel >= f->dcap) cf_grow_directed(f);
  f->uf[f->nel] = f->nel; f->set[f->nel] = CF_EMPTY;
  if (f->why) { f->why[f->nel] = 0; f->why_el[f->nel] = -1; f->usz[f->nel] = 1; }
  return f->nel++;
}

/* ---- directed mode ---- */

/* A container's contents are an object's (Andersen-style points-to, one
   object per allocation: a literal, a builtin's result, a rest parameter's
   Array): an element holds a set of objects, which reaches along the
   edges as the classes do, and a store into an element or a load out of it
   goes to the contents of every object it holds, those it comes to hold
   later included. An element that may hold a container the walk does not
   track (ptop: every element whose classes are every class) loads every
   class; one stored into such a container, or handed to code the walk does
   not see, escapes: its objects' contents may be anything. A share (`a`'s
   and `b`'s containers may be one another's) is a pair of edges that carry
   only the objects. */
static void cf_grow_directed(CF *f) {
  int ncap = f->dcap ? f->dcap * 2 : (f->cel > 1024 ? f->cel : 1024);
  while (ncap <= f->nel) ncap *= 2;
#define CF_GROW(p) do { if (!((p) = realloc((p), sizeof *(p) * (size_t)ncap))) cf_oom(); } while (0)
  CF_GROW(f->succ); CF_GROW(f->nsucc); CF_GROW(f->csucc);
  CF_GROW(f->psucc); CF_GROW(f->npsucc); CF_GROW(f->cpsucc);
  CF_GROW(f->inwl); CF_GROW(f->orig);
  CF_GROW(f->pts); CF_GROW(f->npts); CF_GROW(f->cpts);
  CF_GROW(f->pdel); CF_GROW(f->npdel); CF_GROW(f->cpdel);
  CF_GROW(f->ld); CF_GROW(f->nld); CF_GROW(f->cld);
  CF_GROW(f->st); CF_GROW(f->nst); CF_GROW(f->cst);
  CF_GROW(f->ptop); CF_GROW(f->esc); CF_GROW(f->elobj); CF_GROW(f->summ); CF_GROW(f->smc);
#undef CF_GROW
  for (int i = f->dcap; i < ncap; i++) {
    f->succ[i] = NULL; f->nsucc[i] = 0; f->csucc[i] = 0;
    f->psucc[i] = NULL; f->npsucc[i] = 0; f->cpsucc[i] = 0;
    f->inwl[i] = 0; f->orig[i] = 0;
    f->pts[i] = NULL; f->npts[i] = 0; f->cpts[i] = 0;
    f->pdel[i] = NULL; f->npdel[i] = 0; f->cpdel[i] = 0;
    f->ld[i] = NULL; f->nld[i] = 0; f->cld[i] = 0;
    f->st[i] = NULL; f->nst[i] = 0; f->cst[i] = 0;
    f->ptop[i] = 0; f->esc[i] = 0; f->elobj[i] = -1; f->summ[i] = -1; f->smc[i] = 0;
  }
  f->dcap = ncap;
}
static void cf_wl_push(CF *f, int x) {
  if (f->inwl[x]) return;
  if (f->nwl == f->cwl) {
    f->cwl = f->cwl ? f->cwl * 2 : 1024;
    if (!(f->wl = realloc(f->wl, sizeof *f->wl * (size_t)f->cwl))) cf_oom();
  }
  f->inwl[x] = 1; f->wl[f->nwl++] = x;
}
/* a key not seen before: 1 (an edge, a pts edge, a load or a store) */
static int cf_mark(CF *f, unsigned long long key) {
  if (f->ehn * 2 >= f->ehcap) {
    int ncap = f->ehcap ? f->ehcap * 2 : 1 << 16;
    unsigned long long *nh = calloc((size_t)ncap, sizeof *nh);
    if (!nh) cf_oom();
    for (int i = 0; i < f->ehcap; i++)
      if (f->eh[i]) {
        unsigned h = (unsigned)((f->eh[i] * 0x9E3779B97F4A7C15ULL) >> 33) & (unsigned)(ncap - 1);
        while (nh[h]) h = (h + 1) & (unsigned)(ncap - 1);
        nh[h] = f->eh[i];
      }
    free(f->eh); f->eh = nh; f->ehcap = ncap;
  }
  unsigned h = (unsigned)((key * 0x9E3779B97F4A7C15ULL) >> 33) & (unsigned)(f->ehcap - 1);
  while (f->eh[h]) { if (f->eh[h] == key) return 0; h = (h + 1) & (unsigned)(f->ehcap - 1); }
  f->eh[h] = key; f->ehn++;
  return 1;
}
#define CF_KEY(a, b, kind) ((((unsigned long long)(unsigned)(a) << 32) | (unsigned)(b)) + 1 + ((unsigned long long)(kind) << 62))
static void cf_push_int(int **v, int *n, int *cap, int x) {
  if (*n == *cap) { *cap = *cap ? *cap * 2 : 4; if (!(*v = realloc(*v, sizeof(int) * (size_t)*cap))) cf_oom(); }
  (*v)[(*n)++] = x;
}
static void cf_drain(CF *f);
static void cf_add_set_at(CF *f, int x, int pidx, int line);
static int cf_new_el(CF *f);
/* x may hold a container the walk does not track */
static void cf_escape(CF *f, int e);
#define cf_ptop_set(f, x) cf_ptop_set_at((f), (x), __LINE__)
static void cf_ptop_set_at(CF *f, int x, int line) {
  if (x < 0 || f->ptop[x]) return;
  if (f->dbg_ptop) fprintf(stderr, "cls-flow-ptop: rule %d element %d set-all %d npts %d smc %d\n", line, x, f->set[x] == CF_ALL, f->npts[x], f->smc[x]);
  f->ptop[x] = 1; f->changed = 1;
  for (int i = 0; i < f->nld[x]; i++) cf_add_set_at(f, f->ld[x][i], CF_ALL, __LINE__);
  for (int i = 0; i < f->nst[x]; i++) cf_escape(f, f->st[x][i]);
  cf_wl_push(f, x);
}
static int cf_pts_has(CF *f, int x, int o) {
  int lo = 0, hi = f->npts[x];
  while (lo < hi) { int m = (lo + hi) / 2; if (f->pts[x][m] < o) lo = m + 1; else hi = m; }
  return lo < f->npts[x] && f->pts[x][lo] == o;
}
static void cf_edge(CF *f, int src, int dst);
/* x holds object o */
#define CF_PTS_MAX 64
static int cf_new_obj(CF *f);
static void cf_pts_add(CF *f, int x, int o) {
  if (x < 0 || o < 0 || cf_pts_has(f, x, o)) return;
  /* past the cap, x holds one object whose contents are those of all it
     was handed, joined both ways (Steensgaard over just those contents) */
  if (f->summ[x] >= 0) {
    int ks = f->obj_cont[f->summ[x]], ko = f->obj_cont[o];
    cf_edge(f, ko, ks); cf_edge(f, ks, ko);
    return;
  }
  if (f->npts[x] >= f->pts_max) {
    /* a summary's own contents past the cap join the one global summary
       (no summary of summaries); its own past the cap give up */
    if (f->smc[x] == 2) { cf_ptop_set(f, x); return; }
    if (f->gsum < 0) { f->gsum = cf_new_obj(f); f->smc[f->obj_cont[f->gsum]] = 2; }
    int sm = f->gsum;
    f->summ[x] = sm;
    int ks = f->obj_cont[sm];
    for (int i = 0; i < f->npts[x]; i++) { int ko = f->obj_cont[f->pts[x][i]]; cf_edge(f, ko, ks); cf_edge(f, ks, ko); }
    { int ko = f->obj_cont[o]; cf_edge(f, ko, ks); cf_edge(f, ks, ko); }
    o = sm;     /* the summary is added like any object: it reaches on, loads and stores apply to it */
  }
  int lo = 0, hi = f->npts[x];
  while (lo < hi) { int m = (lo + hi) / 2; if (f->pts[x][m] < o) lo = m + 1; else hi = m; }
  cf_push_int(&f->pts[x], &f->npts[x], &f->cpts[x], o);
  f->st_pts++;
  memmove(&f->pts[x][lo + 1], &f->pts[x][lo], sizeof(int) * (size_t)(f->npts[x] - 1 - lo));
  f->pts[x][lo] = o;
  f->changed = 1;
  int k = f->obj_cont[o];
  for (int i = 0; i < f->nld[x]; i++) cf_edge(f, k, f->ld[x][i]);
  for (int i = 0; i < f->nst[x]; i++) cf_edge(f, f->st[x][i], k);
  if (f->esc[x]) cf_add_set_at(f, k, CF_ALL, __LINE__);
  cf_push_int(&f->pdel[x], &f->npdel[x], &f->cpdel[x], o);
  cf_wl_push(f, x);
}
static void cf_escape(CF *f, int e) {
  if (e < 0 || f->esc[e]) return;
  if (f->dbg_ptop) fprintf(stderr, "cls-flow-esc: element %d node-line %d kind %s name %s file %s\n", e, e < f->nnodes ? (int)nt_int(f->nt, e, "node_line", 0) : -1, e < f->nnodes ? nt_type(f->nt, e) : "slot", e < f->nnodes && nt_str(f->nt, e, "name") ? nt_str(f->nt, e, "name") : "-", e < f->nnodes && nt_file_path(f->nt, (int)nt_int(f->nt, e, "node_file", 0)) ? nt_file_path(f->nt, (int)nt_int(f->nt, e, "node_file", 0)) : "-");
  f->esc[e] = 1; f->changed = 1;
  for (int i = 0; i < f->npts[e]; i++) cf_add_set_at(f, f->obj_cont[f->pts[e][i]], CF_ALL, __LINE__);
}
/* the object x stands for, made on first use (a literal's, a result's) */
static int cf_new_obj(CF *f) {
  int k = cf_new_el(f);
  if (f->nobj == f->cobj) {
    f->cobj = f->cobj ? f->cobj * 2 : 1024;
    if (!(f->obj_cont = realloc(f->obj_cont, sizeof(int) * (size_t)f->cobj))) cf_oom();
  }
  int o = f->nobj++;
  f->obj_cont[o] = k;
  return o;
}
static int cf_el_obj(CF *f, int x) {
  if (x < 0) return -1;
  if (f->elobj[x] >= 0) return f->elobj[x];
  int o = cf_new_obj(f);
  f->elobj[x] = o;
  cf_pts_add(f, x, o);
  return o;
}
/* every set along the edges, until none grows */
static void cf_drain(CF *f) {
  if (f->draining) return;
  f->draining = 1;
  while (f->nwl || f->nfs) {
    if (f->nfs) {
      int dst = f->fs[--f->nfs], src = f->fs[--f->nfs];
      for (int j = 0; j < f->npts[src]; j++) cf_pts_add(f, dst, f->pts[src][j]);
      continue;
    }
    int x = f->wl[--f->nwl];
    f->inwl[x] = 0;
    f->st_drain++;
    /* the objects x gained since it was last sent on (a new edge sends all
       of them itself, cf_edge) */
    int nd = f->npdel[x], *dl = NULL;
    if (nd) { dl = f->pdel[x]; f->pdel[x] = NULL; f->npdel[x] = 0; f->cpdel[x] = 0; }
    for (int i = 0; i < f->nsucc[x]; i++) {
      int y = f->succ[x][i];
      int sx = f->set[x];
      int u = cf_union(f, f->set[y], sx);
      if (u != f->set[y]) {
        if (u == CF_ALL && !f->orig[y]) f->orig[y] = f->orig[x] ? f->orig[x] : -1;
        f->set[y] = u; f->changed = 1; cf_wl_push(f, y);
        if (u == CF_ALL) cf_ptop_set(f, y);
      }
      for (int j = 0; j < nd; j++) cf_pts_add(f, y, dl[j]);
      if (f->ptop[x]) cf_ptop_set(f, y);
    }
    for (int i = 0; i < f->npsucc[x]; i++) {
      int y = f->psucc[x][i];
      for (int j = 0; j < nd; j++) cf_pts_add(f, y, dl[j]);
      if (f->ptop[x]) cf_ptop_set(f, y);
    }
    free(dl);
  }
  f->draining = 0;
}
static void cf_kick(CF *f, int src) {
  if (f->set[src] != CF_EMPTY || f->ptop[src]) cf_wl_push(f, src);
  cf_drain(f);
}
/* an edge src -> dst, once */
static void cf_edge(CF *f, int src, int dst) {
  if (src < 0 || dst < 0 || src == dst) return;
  if (!cf_mark(f, CF_KEY(src, dst, 0))) return;
  cf_push_int(&f->succ[src], &f->nsucc[src], &f->csucc[src], dst);
  f->st_edges++;
  f->changed = 1;
  if (f->npts[src]) { cf_push_int(&f->fs, &f->nfs, &f->cfs, src); cf_push_int(&f->fs, &f->nfs, &f->cfs, dst); }
  cf_kick(f, src);
}
/* an edge that carries only the objects */
static void cf_pedge(CF *f, int src, int dst) {
  if (src < 0 || dst < 0 || src == dst) return;
  if (!cf_mark(f, CF_KEY(src, dst, 1))) return;
  cf_push_int(&f->psucc[src], &f->npsucc[src], &f->cpsucc[src], dst);
  f->changed = 1;
  if (f->npts[src]) { cf_push_int(&f->fs, &f->nfs, &f->cfs, src); cf_push_int(&f->fs, &f->nfs, &f->cfs, dst); }
  if (f->ptop[src]) cf_wl_push(f, src);
  cf_kick(f, src);
}

static int cf_find(CF *f, int x) {
  while (f->uf[x] != x) { f->uf[x] = f->uf[f->uf[x]]; x = f->uf[x]; }
  return x;
}
static void cf_unite_at(CF *f, int a, int b, int line) {
  if (a < 0 || b < 0) return;
  if (f->directed) { (void)line; cf_edge(f, a, b); cf_edge(f, b, a); return; }
  a = cf_find(f, a); b = cf_find(f, b);
  if (a == b) return;
  if (a > b) { int t = a; a = b; b = t; }
  f->uf[b] = a;
  if (f->usz) {
    int lo = f->usz[a] < f->usz[b] ? f->usz[a] : f->usz[b];
    f->usz[a] += f->usz[b];
    if (f->nuev == f->cuev) {
      f->cuev = f->cuev ? f->cuev * 2 : 4096;
      if (!(f->uev = realloc(f->uev, sizeof *f->uev * (size_t)f->cuev))) cf_oom();
    }
    f->uev[f->nuev][0] = line; f->uev[f->nuev][1] = a; f->uev[f->nuev][2] = lo; f->nuev++;
  }
  int sa = f->set[a], sb = f->set[b];
  f->set[a] = cf_union(f, sa, sb);
  if (f->why && f->set[a] == CF_ALL && sa != CF_ALL) {
    f->why[a] = sb == CF_ALL ? f->why[b] : CF_WHY_CAP;
    f->why_el[a] = sb == CF_ALL ? f->why_el[b] : -1;
  }
  f->changed = 1;
}
static void cf_add_set_at(CF *f, int x, int pidx, int line) {
  if (x < 0) return;
  if (f->directed) {
    int u = cf_union(f, f->set[x], pidx);
    if (u != f->set[x]) {
      if (u == CF_ALL && !f->orig[x]) f->orig[x] = pidx == CF_ALL ? line : -line;
      if (u == CF_ALL && f->dbg_seed) fprintf(stderr, "cls-flow-seed: rule %d element %d node-line %d kind %s\n", line, x, x < f->nnodes ? (int)nt_int(f->nt, x, "node_line", 0) : -1, x < f->nnodes ? nt_type(f->nt, x) : "slot");
      f->set[x] = u; f->changed = 1;
      if (u == CF_ALL) cf_ptop_set(f, x);
      cf_wl_push(f, x); cf_drain(f);
    }
    return;
  }
  int x0 = x;
  x = cf_find(f, x);
  int u = cf_union(f, f->set[x], pidx);
  if (u != f->set[x]) {
    if (f->why && u == CF_ALL) { f->why[x] = pidx == CF_ALL ? line : CF_WHY_CAP; f->why_el[x] = x0; }
    f->set[x] = u; f->changed = 1;
  }
}
#define cf_add_set(f, x, pidx) cf_add_set_at((f), (x), (pidx), __LINE__)
#define cf_unite(f, a, b) cf_unite_at((f), (a), (b), __LINE__)
/* a flow from src to dst: an edge in directed mode, else one element */
static void cf_flow_at(CF *f, int src, int dst, int line) {
  if (f->directed) { (void)line; cf_edge(f, src, dst); return; }
  cf_unite_at(f, src, dst, line);
}
#define cf_flow(f, src, dst) cf_flow_at((f), (src), (dst), __LINE__)
/* e stored into container c: e is in the contents of every object c holds
   (c's own, made here, when it holds none: a value whose contents only
   these calls name) */
static void cf_store_at(CF *f, int c, int e, int line) {
  if (f->directed) {
    (void)line; if (c < 0 || e < 0) return;
    if (!cf_mark(f, CF_KEY(c, e, 2))) return;
    cf_push_int(&f->st[c], &f->nst[c], &f->cst[c], e);
    f->changed = 1;
    for (int i = 0; i < f->npts[c]; i++) cf_edge(f, e, f->obj_cont[f->pts[c][i]]);
    if (f->ptop[c]) cf_escape(f, e);
    if (!f->npts[c] && !f->ptop[c]) cf_el_obj(f, c);
    return;
  }
  cf_unite_at(f, c, e, line);
}
#define cf_store(f, c, e) cf_store_at((f), (c), (e), __LINE__)
/* v read out of container c: v holds the contents of every object c holds */
static void cf_load_at(CF *f, int c, int v, int line) {
  if (f->directed) {
    (void)line; if (c < 0 || v < 0) return;
    if (!cf_mark(f, CF_KEY(c, v, 3))) return;
    cf_push_int(&f->ld[c], &f->nld[c], &f->cld[c], v);
    f->changed = 1;
    for (int i = 0; i < f->npts[c]; i++) cf_edge(f, f->obj_cont[f->pts[c][i]], v);
    if (f->ptop[c]) cf_add_set_at(f, v, CF_ALL, __LINE__);
    return;
  }
  cf_unite_at(f, v, c, line);
}
#define cf_load(f, c, v) cf_load_at((f), (c), (v), __LINE__)
/* a's own container holds b's elements (a splat into a literal, a
   builtin's answer built from its receiver, a rest parameter's Array of a
   splat's) */
static void cf_share_at(CF *f, int a, int b, int line) {
  if (f->directed) {
    (void)line; if (a < 0 || b < 0) return;
    int o = cf_el_obj(f, a);
    cf_load_at(f, b, f->obj_cont[o], line);
    return;
  }
  cf_unite_at(f, a, b, line);
}
#define cf_share(f, a, b) cf_share_at((f), (a), (b), __LINE__)
#define cf_all(f, x) cf_add_set_at((f), (x), CF_ALL, __LINE__)
static int cf_set_of(CF *f, int x) { return x < 0 ? CF_ALL : f->set[cf_find(f, x)]; }

/* ---- the slots ---- */

static int cf_scope_of(CF *f, int v) {
  int si = v >= 0 && v < f->nnodes ? f->c->nscope[v] : 0;
  return si < 0 || si >= f->c->nscopes ? 0 : si;
}
/* the element of local `nm` as node v's scope sees it, -1 for none */
static int cf_lv(CF *f, int v, const char *nm) {
  if (!nm) return -1;
  int si = cf_scope_of(f, v);
  Scope *s = &f->c->scopes[si];
  LocalVar *lv = scope_local(s, nm);
  if (!lv) return -1;
  int idx = (int)(lv - s->locals);
  if (idx < 0 || idx >= f->nlv[si]) return -1;
  if (!f->lv_el[si]) {
    f->lv_el[si] = malloc(sizeof(int) * (size_t)(f->nlv[si] + 1));
    if (!f->lv_el[si]) cf_oom();
    for (int k = 0; k < f->nlv[si]; k++) f->lv_el[si][k] = -1;
  }
  if (f->lv_el[si][idx] < 0) f->lv_el[si][idx] = cf_new_el(f);
  return f->lv_el[si][idx];
}
static int cf_lv_in(CF *f, int si, const char *nm) {
  Scope *s = &f->c->scopes[si];
  LocalVar *lv = nm ? scope_local(s, nm) : NULL;
  if (!lv) return -1;
  int idx = (int)(lv - s->locals);
  if (idx < 0 || idx >= f->nlv[si]) return -1;
  if (!f->lv_el[si]) {
    f->lv_el[si] = malloc(sizeof(int) * (size_t)(f->nlv[si] + 1));
    if (!f->lv_el[si]) cf_oom();
    for (int k = 0; k < f->nlv[si]; k++) f->lv_el[si][k] = -1;
  }
  if (f->lv_el[si][idx] < 0) f->lv_el[si][idx] = cf_new_el(f);
  return f->lv_el[si][idx];
}

static unsigned cf_ent_hash(int cls, const char *name) { return sp_strhash(name) * 31u + (unsigned)(cls + 1000); }
/* the element of the (key, name) slot: an ivar by class family, a class's
   own ivar (key -(k+2)), the main object's (-1), a class variable (-2), a
   global (-3), a constant (-4) */
static int cf_entry(CF *f, int cls, const char *name) {
  if (!name) return -1;
  if (f->ent_n * 2 >= f->ent_cap) {
    int ncap = f->ent_cap ? f->ent_cap * 2 : 256;
    CFEntry *nv = calloc((size_t)ncap, sizeof *nv);
    if (!nv) cf_oom();
    for (int k = 0; k < f->ent_cap; k++) {
      if (!f->ent[k].name) continue;
      unsigned j = cf_ent_hash(f->ent[k].cls, f->ent[k].name) & (unsigned)(ncap - 1);
      while (nv[j].name) j = (j + 1) & (unsigned)(ncap - 1);
      nv[j] = f->ent[k];
    }
    free(f->ent); f->ent = nv; f->ent_cap = ncap;
  }
  unsigned j = cf_ent_hash(cls, name) & (unsigned)(f->ent_cap - 1);
  while (f->ent[j].name) {
    if (f->ent[j].cls == cls && sp_streq(f->ent[j].name, name)) return f->ent[j].el;
    j = (j + 1) & (unsigned)(f->ent_cap - 1);
  }
  char *own = strdup(name);
  if (!own) cf_oom();
  f->ent[j].cls = cls; f->ent[j].name = own; f->ent[j].el = cf_new_el(f);
  f->ent_n++;
  return f->ent[j].el;
}
/* is there a (key, name) slot already? */
static int cf_entry_has(CF *f, int cls, const char *name) {
  if (!name || !f->ent_cap) return 0;
  unsigned j = cf_ent_hash(cls, name) & (unsigned)(f->ent_cap - 1);
  while (f->ent[j].name) {
    if (f->ent[j].cls == cls && sp_streq(f->ent[j].name, name)) return 1;
    j = (j + 1) & (unsigned)(f->ent_cap - 1);
  }
  return 0;
}
#define CF_K_MAIN  (-1)
#define CF_K_CVAR  (-2)
#define CF_K_GVAR  (-3)
#define CF_K_CONST (-4)
#define CF_K_CONSTW (-5)   /* a constant the program writes (by its last segment) */

/* a method the compiler supplies (builtins/*.rb, spliced in and marked
   node_bi; a desugar's synthesized def): calls the desugars make reach it
   after this pass, so its parameters and its self take anything, and a
   call that resolves to it is answered as the builtin it implements */
static int cf_prelude_scope(CF *f, int mi) {
  Scope *s = &f->c->scopes[mi];
  if (s->def_node < 0) return 0;
  return nt_int(f->nt, s->def_node, "node_bi", 0) != 0 || nt_int(f->nt, s->def_node, "node_line", 0) == 0;
}
/* does class k carry native bindings (ffi_func, a Fiddle extern): a call
   on it the program's own methods do not answer may be one of those, whose
   value is anything */
static int cf_class_has_natives(CF *f, int k) {
  if (k < 0 || k >= f->c->nclasses) return 0;
  if (!f->has_native) {
    f->has_native = calloc((size_t)f->c->nclasses + 1, 1);
    if (!f->has_native) cf_oom();
    for (int i = 0; i < f->c->n_native_methods; i++) {
      int ck = f->c->native_methods[i].class_id;
      if (ck >= 0 && ck < f->c->nclasses) f->has_native[ck] = 1;
    }
  }
  return f->has_native[k] || f->c->classes[k].is_native_class;
}
/* a top-level class or module of the runtime's that the program reopens
   (Object, Kernel, Comparable, String, Exception, ...): its methods run for
   objects the program's classes do not list, its own subclasses and
   includers among them */
static int cf_open_self(CF *f, int k) {
  ClassInfo *ci = &f->c->classes[k];
  const char *nm = ci->name;
  if (!nm || ci->enclosing_class >= 0) return 0;
  return is_builtin_reopen_name(nm) || is_object_root(nm) || is_builtin_class_name(nm) ||
         is_builtin_module_name(nm) || is_builtin_exception_name(nm);
}
/* a Kernel function or a class body's declaration: a receiverless call
   whose answer does not come from self */
static int cf_selfless_fn(const char *nm) {
  static const char *const names[] = { "puts", "print", "p", "pp", "printf", "sprintf", "format", "putc",
    "raise", "fail", "require", "require_relative", "load", "sleep", "rand", "srand", "Integer", "Float",
    "String", "Array", "Hash", "Rational", "Complex", "loop", "catch", "throw", "lambda", "proc",
    "block_given?", "binding", "caller", "caller_locations", "exit", "exit!", "abort", "at_exit", "gets",
    "warn", "open", "system", "spawn", "`", "select", "trap", "fork", "exec", "autoload", "readline",
    "readlines", "__method__", "__dir__", "attr_reader", "attr_writer", "attr_accessor", "attr", "private",
    "public", "protected", "module_function", "include", "prepend", "define_method", "alias_method",
    "remove_method", "undef_method", "private_constant", "private_class_method", "public_class_method", NULL };
  for (int i = 0; names[i]; i++) if (sp_streq(nm, names[i])) return 1;
  return 0;
}
/* a scope's instance class: the class whose instances run it, -1 for a
   class method, a class body or the top level */
static int cf_inst_class(CF *f, int si) {
  Scope *s = &f->c->scopes[si];
  return s->def_node >= 0 && !s->is_cmethod && s->class_id >= 0 ? s->class_id : -1;
}
/* the ivar slots node v's scope reads `name` from, into out (at most max) */
static int cf_ivar_els(CF *f, int v, const char *name, int *out, int max) {
  Compiler *c = f->c;
  int si = cf_scope_of(f, v), n = 0;
  int k = cf_inst_class(f, si);
  if (k >= 0 && !f->mod[k]) { out[n++] = cf_entry(f, f->fam[k], name); return n; }
  if (k >= 0) {
    /* a module's method runs in its includers */
    for (int i = 0; i < c->nclasses && n < max - 1; i++) {
      if (f->mod[i]) continue;
      int inc = 0;
      for (int m = 0; m < c->classes[i].nincluded_mods && !inc; m++)
        if (c->classes[i].included_mods[m] == k) inc = 1;
      if (inc) out[n++] = cf_entry(f, f->fam[i], name);
    }
    out[n++] = cf_entry(f, CF_K_MAIN, name);
    return n;
  }
  Scope *s = &c->scopes[si];
  int ck = s->def_node >= 0 && s->is_cmethod ? s->class_id
         : v >= 0 && v < f->nnodes && c->node_cbody ? c->node_cbody[v] : -1;
  out[n++] = cf_entry(f, ck >= 0 ? -(ck + 2) : CF_K_MAIN, name);
  return n;
}
/* `X.name` or `X.name = v` through a `class << self` accessor of class k:
   k's class-level ivar, the slot its class body and its class methods name
   `@name` (an over-approximation where the accessor's storage is its own) */
static int cf_sg_access(CF *f, int v, int k, const char *nm, const int *argv, int argc) {
  ClassInfo *ci = &f->c->classes[k];
  char ivn[256];
  if (argc == 0 && comp_is_sg_reader(ci, nm)) {
    snprintf(ivn, sizeof ivn, "@%s", nm);
    if (v >= 0) cf_flow(f, cf_entry(f, -(k + 2), ivn), v);
    return 1;
  }
  char base[256];
  if (setter_base_name(nm, base, sizeof base)) {
    if (!comp_is_sg_writer(ci, base)) return 0;
    char wivn[sizeof base + 1];
    snprintf(wivn, sizeof wivn, "@%s", base);
    int e = cf_entry(f, -(k + 2), wivn);
    for (int a = 0; a < argc; a++) { cf_flow(f, argv[a], e); if (v >= 0) cf_flow(f, argv[a], v); }
    return 1;
  }
  return 0;
}
/* the last segment of a constant path's name */
static const char *cf_const_key(const char *name) {
  if (!name) return NULL;
  const char *p = strrchr(name, ':');
  return p ? p + 1 : name;
}

/* ---- the classes ---- */

static int cf_is_class_const(CF *f, int n) {
  if (n < 0) return -1;
  NodeKind k = nt_kind(f->nt, n);
  if (k != NK_ConstantReadNode && k != NK_ConstantPathNode) return -1;
  return comp_class_index(f->c, nt_str(f->nt, n, "name"));
}
/* the methods named `name`, memoized: the class structure does not move
   during the pass */
static CFByName *cf_byname(CF *f, const char *name) {
  Compiler *c = f->c;
  if (f->bn_n * 2 >= f->bn_cap) {
    int ncap = f->bn_cap ? f->bn_cap * 2 : 512;
    CFByName *nv = calloc((size_t)ncap, sizeof *nv);
    if (!nv) cf_oom();
    for (int k = 0; k < f->bn_cap; k++) {
      if (!f->bn[k].name) continue;
      unsigned j = sp_strhash(f->bn[k].name) & (unsigned)(ncap - 1);
      while (nv[j].name) j = (j + 1) & (unsigned)(ncap - 1);
      nv[j] = f->bn[k];
    }
    free(f->bn); f->bn = nv; f->bn_cap = ncap;
  }
  unsigned j = sp_strhash(name) & (unsigned)(f->bn_cap - 1);
  while (f->bn[j].name) {
    if (sp_streq(f->bn[j].name, name)) return &f->bn[j];
    j = (j + 1) & (unsigned)(f->bn_cap - 1);
  }
  CFByName *e = &f->bn[j];
  e->name = strdup(name);
  if (!e->name) cf_oom();
  f->bn_n++;
  int cap = 8, ccap = 4, rcap = 4, wcap = 4;
  e->mi = malloc(sizeof(int) * (size_t)cap); e->cmi = malloc(sizeof(int) * (size_t)ccap);
  e->rd = malloc(sizeof(int) * (size_t)rcap); e->wr = malloc(sizeof(int) * (size_t)wcap);
  if (!e->mi || !e->cmi || !e->rd || !e->wr) cf_oom();
  char base[256];
  int is_w = setter_base_name(name, base, sizeof base);
  for (int k = 0; k < c->nclasses; k++) {
    int mi = comp_method_in_chain(c, k, name, NULL);
    if (mi >= 0) {
      int seen = 0;
      for (int i = 0; i < e->n; i++) if (e->mi[i] == mi) { seen = 1; break; }
      if (!seen) {
        if (e->n == cap) { cap *= 2; e->mi = realloc(e->mi, sizeof(int) * (size_t)cap); if (!e->mi) cf_oom(); }
        e->mi[e->n++] = mi;
      }
    }
    int cm = comp_cmethod_in_chain(c, k, name, NULL);
    if (cm >= 0) {
      int seen = 0;
      for (int i = 0; i < e->ncm; i++) if (e->cmi[i] == cm) { seen = 1; break; }
      if (!seen) {
        if (e->ncm == ccap) { ccap *= 2; e->cmi = realloc(e->cmi, sizeof(int) * (size_t)ccap); if (!e->cmi) cf_oom(); }
        e->cmi[e->ncm++] = cm;
      }
    }
    if (comp_reader_in_chain(c, k, name, NULL)) {
      if (e->nrd == rcap) { rcap *= 2; e->rd = realloc(e->rd, sizeof(int) * (size_t)rcap); if (!e->rd) cf_oom(); }
      e->rd[e->nrd++] = k;
    }
    if (is_w && comp_writer_in_chain(c, k, base, NULL)) {
      if (e->nwr == wcap) { wcap *= 2; e->wr = realloc(e->wr, sizeof(int) * (size_t)wcap); if (!e->wr) cf_oom(); }
      e->wr[e->nwr++] = k;
    }
  }
  int tl = comp_method_index(c, name);
  if (tl >= 0) {
    int seen = 0;
    for (int i = 0; i < e->n; i++) if (e->mi[i] == tl) { seen = 1; break; }
    if (!seen) {
      if (e->n == cap) { cap *= 2; e->mi = realloc(e->mi, sizeof(int) * (size_t)cap); if (!e->mi) cf_oom(); }
      e->mi[e->n++] = tl;
    }
  }
  return e;
}

static int cf_is_dyn(CF *f, const char *name) {
  if (f->dyn_all) return 1;
  for (int i = 0; i < f->ndyn; i++) if (sp_streq(f->dyn[i], name)) return 1;
  return 0;
}
static void cf_dyn_add(CF *f, const char *name) {
  if (!name) return;
  if (f->ndyn == f->cdyn) {
    f->cdyn = f->cdyn ? f->cdyn * 2 : 16;
    f->dyn = realloc(f->dyn, sizeof *f->dyn * (size_t)f->cdyn);
    if (!f->dyn) cf_oom();
  }
  f->dyn[f->ndyn++] = name;
}

/* a method name whose call the analysis cannot follow: its value, and
   where its arguments go, are unknown */
static int cf_opaque_name(const char *nm) {
  static const char *const names[] = {
    "send", "__send__", "public_send", "method", "public_method", "instance_method",
    "singleton_method", "define_method", "define_singleton_method", "instance_variable_get",
    "instance_variable_set", "instance_variables", "instance_exec", "instance_eval", "class_eval",
    "class_exec", "module_eval", "module_exec", "const_get", "const_set", "eval", "binding",
    "catch", "throw", "method_missing", "remove_instance_variable", "singleton_class", "extend",
    "local_variable_get", "local_variable_set", "receiver", "owner", "unbind", "bind", "bind_call",
    "__method__", "caller", "caller_locations", "ObjectSpace", "superclass", "subclasses", "ancestors",
    "included_modules", "instance_methods", "public_instance_methods", "const_source_location", NULL };
  for (int i = 0; names[i]; i++) if (sp_streq(nm, names[i])) return 1;
  return 0;
}
/* the runtime module whose protocol a method of the name is; NULL for one
   any builtin may call (to_s, ==, each, ...) */
static const char *cf_protocol_gate(const char *nm) {
  if (sp_streq(nm, "marshal_dump") || sp_streq(nm, "marshal_load") || sp_streq(nm, "_dump") || sp_streq(nm, "_load")) return "Marshal";
  if (sp_streq(nm, "encode_with") || sp_streq(nm, "init_with")) return "Psych";
  if (sp_streq(nm, "pretty_print")) return "PP";
  if (sp_streq(nm, "to_json") || sp_streq(nm, "as_json")) return "JSON";
  return NULL;
}
/* does the program read a constant of the name anywhere (YAML for Psych)? */
static int cf_const_named(CF *f, const char *nm) {
  const NodeTable *nt = f->nt;
  int yaml = sp_streq(nm, "Psych");
  NT_FOREACH_KIND(nt, NK_ConstantReadNode, id) {
    const char *cn = nt_str(nt, id, "name");
    if (cn && (sp_streq(cn, nm) || (yaml && sp_streq(cn, "YAML")))) return 1;
  }
  NT_FOREACH_KIND(nt, NK_ConstantPathNode, id) {
    const char *cn = nt_str(nt, id, "name");
    if (cn && (sp_streq(cn, nm) || (yaml && sp_streq(cn, "YAML")))) return 1;
  }
  return 0;
}
/* an operator every builtin answers with a value of its own kind (a
   number, a bool, a new container), or with the receiver (`<<`); not `[]`,
   `[]=` or `===` (a Proc's runs it) */
static int cf_builtin_operator(const char *nm) {
  static const char *const names[] = { "+", "-", "*", "/", "%", "**", "&", "|", "^", "<<", ">>", "<=>", "==", "!=",
    "<", "<=", ">", ">=", "-@", "+@", "~", "!", "=~", "!~", NULL };
  for (int i = 0; nm && names[i]; i++) if (sp_streq(nm, names[i])) return 1;
  return 0;
}
/* Kernel's conversion functions, named like the class they answer */
static int cf_kernel_conversion(const char *nm) {
  static const char *const names[] = { "Integer", "Float", "String", "Rational", "Complex", "Array", "Hash", NULL };
  for (int i = 0; nm && names[i]; i++) if (sp_streq(nm, names[i])) return 1;
  return 0;
}
/* a constant whose methods hand out values from anywhere */
static int cf_poison_const(const char *nm) {
  static const char *const names[] = { "Marshal", "ObjectSpace", "Fiber", "Thread", "Ractor", "Binding",
    "TracePoint", "YAML", "Psych", "Kernel", "BasicObject", "Module", "Class", "Method", "UnboundMethod",
    "RubyVM", "ThreadGroup", "DRb", "PP", NULL };
  for (int i = 0; names[i]; i++) if (sp_streq(nm, names[i])) return 1;
  return 0;
}
/* a method the runtime calls back with arguments of its own */
static int cf_protocol_name(const char *nm) {
  static const char *const names[] = {
    "to_s", "inspect", "==", "!=", "eql?", "equal?", "hash", "<=>", "===", "=~", "!~", "<", "<=", ">", ">=",
    "+", "-", "*", "/", "%", "**", "&", "|", "^", "<<", ">>", "!", "~", "+@", "-@", "[]", "[]=",
    "each", "each_pair", "call", "to_proc", "to_ary", "to_a", "to_h", "to_hash", "to_str", "to_int",
    "to_i", "to_f", "to_r", "to_c", "to_sym", "to_path", "to_io", "to_json", "as_json", "coerce",
    "succ", "pred", "dup", "clone", "initialize_copy", "initialize_dup", "initialize_clone",
    "method_missing", "respond_to?", "respond_to_missing?", "exception", "message", "backtrace",
    "set_backtrace", "cause", "full_message", "detailed_message", "marshal_dump", "marshal_load",
    "_dump", "_load", "encode_with", "init_with", "pretty_print", "inherited", "included", "extended",
    "prepended", "method_added", "singleton_method_added", "const_missing", "write", "print", "puts",
    "read", "getc", "gets", "readpartial", "sysread", "syswrite", "close", "flush", "sync", "fileno",
    "tty?", "isatty", "binmode", "external_encoding", "set_encoding", "path", "size", "length", "empty?",
    "fetch", "key?", "keys", "values", "include?", "between?", "clamp", "step", "divmod", "fdiv",
    "arity", "curry", "parameters", "lambda?", "yield", "deconstruct", "deconstruct_keys", "freeze",
    "frozen?", "each_entry", "first", "last", "min", "max", "sum", "count", "find", "select", "map",
    "reject", "sort", "sort_by", "reduce", "inject", "zip", "each_with_index", "each_with_object",
    "entries", "lazy", "with_index", "next", "peek", "rewind", "default", "default_proc", "compare_by_identity",
    "join", "flatten", "concat", "push", "pop", "shift", "unshift", "insert", "delete", "delete_at",
    "delete_if", "slice", "dig", "values_at", "merge", "update", "store", "key", "invert", "transform_values",
    "replace", "clear", "then", "yield_self", "tap", "itself", "display", "nil?", "is_a?", "kind_of?",
    "instance_of?", "class", "object_id", "__id__", "singleton_methods", "methods", "public_methods",
    "define_method", "attr_accessor", "attr_reader", "attr_writer", "new", "allocate", "superclass",
    "ancestors", "name", "instance_methods", "const_get", "exit", "at_exit", "trap", NULL };
  for (int i = 0; names[i]; i++) if (sp_streq(nm, names[i])) return 1;
  return 0;
}

/* the statements' value: the last one, -1 for none */
static int cf_tail(CF *f, int st) {
  if (st < 0) return -1;
  if (nt_kind(f->nt, st) != NK_StatementsNode) return st;
  int n = 0; const int *b = nt_arr(f->nt, st, "body", &n);
  return n > 0 ? b[n - 1] : -1;
}
static int cf_unparen(CF *f, int v) {
  for (int d = 0; v >= 0 && d < 16 && nt_kind(f->nt, v) == NK_ParenthesesNode; d++) v = cf_tail(f, nt_ref(f->nt, v, "body"));
  return v;
}

/* a block's or a lambda's parameter names, into out; -1 for a splat, a
   keyword or a rest among them (the positions past it are unknown) */
static int cf_block_params(CF *f, int blk, const char **out, int max, int *plain) {
  const NodeTable *nt = f->nt;
  int n = 0;
  *plain = 1;
  int bp = nt_ref(nt, blk, "parameters");
  if (bp < 0) return 0;
  int pn = nt_kind(nt, bp) == NK_BlockParametersNode ? nt_ref(nt, bp, "parameters") : bp;
  if (nt_kind(nt, bp) == NK_NumberedParametersNode) {
    for (int i = 0; i < max; i++) {
      const char *nm = block_param_name(f->c, blk, i);
      if (!nm) break;
      out[n++] = nm;
    }
    return n;
  }
  if (pn < 0 || nt_kind(nt, pn) != NK_ParametersNode) return 0;
  int rn = 0; const int *rq = nt_arr(nt, pn, "requireds", &rn);
  for (int i = 0; i < rn && n < max; i++) {
    const char *nm = nt_kind(nt, rq[i]) == NK_RequiredParameterNode ? nt_str(nt, rq[i], "name") : NULL;
    if (!nm && nt_kind(nt, rq[i]) != NK_MultiTargetNode) { *plain = 0; continue; }
    out[n++] = nm;   /* NULL: a destructuring `|(a, b)|`, bound by cf_bind_destructured */
  }
  int on = 0; const int *op = nt_arr(nt, pn, "optionals", &on);
  for (int i = 0; i < on && n < max; i++) { out[n++] = nt_str(nt, op[i], "name"); }
  int pon = 0; nt_arr(nt, pn, "posts", &pon);
  int kn = 0; nt_arr(nt, pn, "keywords", &kn);
  if (pon > 0 || kn > 0 || nt_ref(nt, pn, "rest") >= 0 || nt_ref(nt, pn, "keyword_rest") >= 0) *plain = 0;
  return n;
}
/* every name a block, a lambda or a def declares as a parameter, into out */
static int cf_all_param_names(CF *f, int params_owner, const char **out, int max) {
  const NodeTable *nt = f->nt;
  int bp = nt_ref(nt, params_owner, "parameters");
  if (bp < 0) return 0;
  if (nt_kind(nt, bp) == NK_NumberedParametersNode) {
    int n = 0;
    for (int i = 0; i < max; i++) {
      const char *nm = block_param_name(f->c, params_owner, i);
      if (!nm) break;
      out[n++] = nm;
    }
    return n;
  }
  int pn = nt_kind(nt, bp) == NK_BlockParametersNode ? nt_ref(nt, bp, "parameters") : bp;
  if (pn < 0) return 0;
  static const char *const lists[] = { "requireds", "optionals", "posts", "keywords", NULL };
  int n = 0;
  for (int l = 0; lists[l]; l++) {
    int ln = 0; const int *ps = nt_arr(nt, pn, lists[l], &ln);
    for (int i = 0; i < ln && n < max; i++) {
      const char *nm = nt_str(nt, ps[i], "name");
      if (nm) out[n++] = nm;
    }
  }
  static const char *const refs[] = { "rest", "keyword_rest", "block", NULL };
  for (int r = 0; refs[r]; r++) {
    int p = nt_ref(nt, pn, refs[r]);
    const char *nm = p >= 0 ? nt_str(nt, p, "name") : NULL;
    if (nm && n < max) out[n++] = nm;
  }
  return n;
}
/* the names a destructuring parameter `|(a, (b, *c)), d|` of a block or a
   lambda binds, each with the position of the required parameter it is
   part of (pos, -1 for a post's) and whether it takes the rest as an
   Array (splat) */
static int cf_destructured_collect(CF *f, int t, int pos, int splat, const char **names, int *poss,
                                   unsigned char *splats, int n, int max) {
  const NodeTable *nt = f->nt;
  if (t < 0 || n >= max) return n;
  NodeKind k = nt_kind(nt, t);
  if (k == NK_MultiTargetNode) {
    static const char *const parts[] = { "lefts", "rights" };
    for (int a = 0; a < 2; a++) {
      int ln = 0; const int *ps = nt_arr(nt, t, parts[a], &ln);
      for (int i = 0; i < ln; i++) n = cf_destructured_collect(f, ps[i], pos, 0, names, poss, splats, n, max);
    }
    int r = nt_ref(nt, t, "rest");
    if (r >= 0 && nt_kind(nt, r) == NK_SplatNode)
      n = cf_destructured_collect(f, nt_ref(nt, r, "expression"), pos, 1, names, poss, splats, n, max);
    return n;
  }
  if (k == NK_LocalVariableTargetNode && nt_str(nt, t, "name")) {
    names[n] = nt_str(nt, t, "name"); poss[n] = pos; splats[n] = (unsigned char)splat; n++;
  }
  return n;
}
static int cf_destructured_params(CF *f, int blk, const char **names, int *poss, unsigned char *splats, int max) {
  const NodeTable *nt = f->nt;
  int bp = nt_ref(nt, blk, "parameters");
  if (bp < 0 || nt_kind(nt, bp) == NK_NumberedParametersNode) return 0;
  int pn = nt_kind(nt, bp) == NK_BlockParametersNode ? nt_ref(nt, bp, "parameters") : bp;
  if (pn < 0 || nt_kind(nt, pn) != NK_ParametersNode) return 0;
  int n = 0;
  int rn = 0; const int *rq = nt_arr(nt, pn, "requireds", &rn);
  for (int i = 0; i < rn; i++)
    if (nt_kind(nt, rq[i]) == NK_MultiTargetNode) n = cf_destructured_collect(f, rq[i], i, 0, names, poss, splats, n, max);
  int pon = 0; const int *po = nt_arr(nt, pn, "posts", &pon);
  for (int i = 0; i < pon; i++)
    if (nt_kind(nt, po[i]) == NK_MultiTargetNode) n = cf_destructured_collect(f, po[i], -1, 0, names, poss, splats, n, max);
  return n;
}
/* is target node v a name a block's or a lambda's destructuring parameter
   binds (cf_destructured_params)? The rules that bind the block's
   parameters give it its classes. */
static int cf_destructured_block_param(CF *f, int v) {
  const NodeTable *nt = f->nt;
  if (!f->par) return 0;
  int p = f->par[v], seen = 0;
  while (p >= 0 && (nt_kind(nt, p) == NK_MultiTargetNode || nt_kind(nt, p) == NK_SplatNode)) { seen = 1; p = f->par[p]; }
  if (!seen || p < 0 || nt_kind(nt, p) != NK_ParametersNode) return 0;
  p = f->par[p];
  if (p >= 0 && nt_kind(nt, p) == NK_BlockParametersNode) p = f->par[p];
  return p >= 0 && (nt_kind(nt, p) == NK_BlockNode || nt_kind(nt, p) == NK_LambdaNode);
}
/* name q, a destructuring parameter's, bound from pe, what the parameter
   takes as a whole: an element of it, the value itself (a non-Array is
   taken whole, with nil for the others), what a to_ary of the program's
   answers; the rest takes an Array of them */
static void cf_bind_destructured(CF *f, int blk, const char *q, int pe, int splat) {
  int body = nt_ref(f->nt, blk, "body");
  int lq = cf_lv(f, body >= 0 ? body : blk, q);
  if (lq < 0) return;
  if (splat || pe < 0) { cf_all(f, lq); return; }
  cf_flow(f, pe, lq);
  cf_load(f, pe, lq);
  CFByName *b = cf_byname(f, "to_ary");
  for (int i = 0; i < b->n; i++) if (!cf_prelude_scope(f, b->mi[i])) cf_load(f, f->ret_el[b->mi[i]], lq);
}
/* the local targets of a multiple assignment node mw (lefts, rights, a
   splat rest, a nested MultiTargetNode), bound from val (cf_masgn_targets);
   depth bounds the nesting */
static void cf_masgn_targets(CF *f, int mw, int val, int depth) {
  const NodeTable *nt = f->nt;
  static const char *const parts[] = { "lefts", "rights" };
  for (int a = 0; a < 2; a++) {
    int ln = 0; const int *ps = nt_arr(nt, mw, parts[a], &ln);
    for (int i = 0; i < ln; i++) {
      int t = ps[i];
      NodeKind k = nt_kind(nt, t);
      if (k == NK_LocalVariableTargetNode) {
        int lq = cf_lv(f, t, nt_str(nt, t, "name"));
        if (lq < 0) continue;
        if (val < 0) { cf_all(f, lq); continue; }
        cf_flow(f, val, lq);
        cf_load(f, val, lq);
        CFByName *b = cf_byname(f, "to_ary");
        for (int j = 0; j < b->n; j++) if (!cf_prelude_scope(f, b->mi[j])) cf_load(f, f->ret_el[b->mi[j]], lq);
      }
      else if (k == NK_MultiTargetNode && depth < 8) {
        /* an element of the value, destructured again */
        int e = -1;
        if (val >= 0) { e = cf_entry(f, -(t + 2), "#mt"); cf_flow(f, val, e); cf_load(f, val, e); }
        cf_masgn_targets(f, t, e, depth + 1);
      }
    }
  }
  int r = nt_ref(nt, mw, "rest");
  if (r >= 0 && nt_kind(nt, r) == NK_SplatNode) {
    int e = nt_ref(nt, r, "expression");
    if (e >= 0 && nt_kind(nt, e) == NK_LocalVariableTargetNode) cf_all(f, cf_lv(f, e, nt_str(nt, e, "name")));
  }
}
/* is target node v a local a multiple assignment binds (cf_masgn_targets)? */
static int cf_masgn_target(CF *f, int v) {
  const NodeTable *nt = f->nt;
  if (!f->par) return 0;
  int p = f->par[v];
  while (p >= 0 && (nt_kind(nt, p) == NK_MultiTargetNode || nt_kind(nt, p) == NK_SplatNode)) p = f->par[p];
  return p >= 0 && nt_kind(nt, p) == NK_MultiWriteNode;
}
static void cf_all_block_params(CF *f, int blk) {
  const char *names[64];
  int n = cf_all_param_names(f, blk, names, 64);
  int body = nt_ref(f->nt, blk, "body");
  for (int i = 0; i < n; i++) cf_all(f, cf_lv(f, body >= 0 ? body : blk, names[i]));
  int poss[64]; unsigned char splats[64];
  n = cf_destructured_params(f, blk, names, poss, splats, 64);
  for (int i = 0; i < n; i++) cf_all(f, cf_lv(f, body >= 0 ? body : blk, names[i]));
}

/* the owning method of node v: the DefNode above it, -1 at the top level
   or inside a lambda that comes first (when lambda_stop) */
static int cf_owner_def(CF *f, int v, int lambda_stop, int *lambda) {
  if (lambda) *lambda = -1;
  if (lambda_stop)
    for (int q = f->par ? f->par[v] : -1, d = 0; q >= 0 && d < 100000; q = f->par[q], d++) {
      NodeKind k = nt_kind(f->nt, q);
      if (k == NK_LambdaNode) { if (lambda) *lambda = q; return -1; }
      if (k == NK_DefNode || k == NK_ClassNode || k == NK_ModuleNode || k == NK_SingletonClassNode) break;
    }
  /* the owning scope, which a synthesized def's detached subtree still has */
  int si = cf_scope_of(f, v);
  return si > 0 && f->c->scopes[si].def_node >= 0 ? si : -1;
}
/* the block above node v (a BlockNode, a LambdaNode), stopping at a def;
   -1 for none */
static int cf_owner_block(CF *f, int v, int loop_stop) {
  for (int q = f->par ? f->par[v] : -1, d = 0; q >= 0 && d < 100000; q = f->par[q], d++) {
    NodeKind k = nt_kind(f->nt, q);
    if (k == NK_BlockNode || k == NK_LambdaNode) return q;
    if (loop_stop && (k == NK_WhileNode || k == NK_UntilNode || k == NK_ForNode)) return -1;
    if (k == NK_DefNode || k == NK_ClassNode || k == NK_ModuleNode) return -1;
  }
  return -1;
}

static int cf_in_exec_block(CF *f, int v);
static void cf_ivar_write_any(CF *f, const char *name, int v);

/* the loop a break under v leaves: the nearest enclosing while, until or
   for, or -1 when a block, a lambda or a def is nearer */
static int cf_owner_loop(CF *f, int v) {
  for (int q = f->par ? f->par[v] : -1, d = 0; q >= 0 && d < 100000; q = f->par[q], d++) {
    NodeKind k = nt_kind(f->nt, q);
    if (k == NK_WhileNode || k == NK_UntilNode || k == NK_ForNode) return q;
    if (k == NK_BlockNode || k == NK_LambdaNode || k == NK_DefNode || k == NK_ClassNode || k == NK_ModuleNode) return -1;
  }
  return -1;
}

/* ---- parameters ---- */

/* is parameter idx of method m a keyword parameter? */
static int cf_param_is_kw(CF *f, Scope *m, int idx) {
  const NodeTable *nt = f->nt;
  if (m->def_node < 0 || idx == m->rest_idx || idx == m->kwrest_idx) return 0;
  int pn = nt_ref(nt, m->def_node, "parameters");
  int kn = 0; const int *kws = pn >= 0 ? nt_arr(nt, pn, "keywords", &kn) : NULL;
  for (int i = 0; i < kn; i++) {
    const char *nm = nt_str(nt, kws[i], "name");
    if (nm && m->pnames[idx] && sp_streq(nm, m->pnames[idx])) return 1;
  }
  return 0;
}
static int cf_param_el(CF *f, int mi, int idx) {
  Scope *m = &f->c->scopes[mi];
  if (idx < 0 || idx >= m->nparams || !m->pnames[idx]) return -1;
  return cf_lv_in(f, mi, m->pnames[idx]);
}
static void cf_all_params(CF *f, int mi) {
  Scope *m = &f->c->scopes[mi];
  for (int i = 0; i < m->nparams; i++) cf_all(f, cf_param_el(f, mi, i));
  if (m->blk_param && m->blk_param[0]) cf_all(f, cf_lv_in(f, mi, m->blk_param));
}
/* the call's arguments to method mi's parameters */
static void cf_bind_args(CF *f, int mi, const int *argv, int argc) {
  const NodeTable *nt = f->nt;
  Compiler *c = f->c;
  if (mi < 0 || mi >= c->nscopes) return;
  Scope *m = &c->scopes[mi];
  int pos[256], npos = 0, splat = 0, kwh = -1, fwd = 0;
  for (int i = 0; i < argc; i++) {
    NodeKind k = nt_kind(nt, argv[i]);
    if (k == NK_BlockArgumentNode) continue;
    if (k == NK_ForwardingArgumentsNode) { fwd = 1; continue; }
    if (k == NK_KeywordHashNode) { kwh = argv[i]; continue; }
    if (k == NK_SplatNode) splat = 1;
    if (npos < 256) pos[npos++] = argv[i];
  }
  if (fwd) { cf_all_params(f, mi); return; }
  /* the positional parameters, in order */
  int ppos[256], np = 0, has_kw = 0;
  for (int i = 0; i < m->nparams && np < 256; i++) {
    if (i == m->kwrest_idx) { has_kw = 1; continue; }
    if (cf_param_is_kw(f, m, i)) { has_kw = 1; continue; }
    ppos[np++] = i;
  }
  /* a keyword hash the method takes as a positional Hash */
  if (kwh >= 0 && !has_kw && npos < 256) { pos[npos++] = kwh; kwh = -1; }
  if (splat || m->rest_idx >= 0 || m->npost_rest > 0 || npos > np) {
    /* the positions are not known: every argument may reach every parameter */
    for (int i = 0; i < np; i++)
      for (int a = 0; a < npos; a++) {
        int an = nt_kind(nt, pos[a]) == NK_SplatNode ? nt_ref(nt, pos[a], "expression") : pos[a];
        int pe = cf_param_el(f, mi, ppos[i]);
        cf_flow(f, an, pe);
        if (ppos[i] == m->rest_idx) cf_store(f, pe, an);
        /* a splat hands on its Array's elements */
        if (an != pos[a]) { cf_load(f, an, pe); if (ppos[i] == m->rest_idx) cf_share(f, pe, an); }
      }
  }
  else {
    for (int a = 0; a < npos && a < np; a++) cf_flow(f, pos[a], cf_param_el(f, mi, ppos[a]));
  }
  if (kwh >= 0) {
    int en = 0; const int *els = nt_arr(nt, kwh, "elements", &en);
    for (int e = 0; e < en; e++) {
      int key = nt_kind(nt, els[e]) == NK_AssocNode ? nt_ref(nt, els[e], "key") : -1;
      const char *kn = key >= 0 && nt_kind(nt, key) == NK_SymbolNode ? nt_str(nt, key, "value") : NULL;
      int val = nt_ref(nt, els[e], "value");
      int bound = 0;
      if (kn) {
        for (int i = 0; i < m->nparams; i++)
          if (m->pnames[i] && sp_streq(m->pnames[i], kn) && cf_param_is_kw(f, m, i)) { cf_flow(f, val, cf_param_el(f, mi, i)); bound = 1; }
        if (m->kwrest_idx >= 0) { cf_flow(f, val, cf_param_el(f, mi, m->kwrest_idx)); cf_store(f, cf_param_el(f, mi, m->kwrest_idx), val); bound = 1; }
      }
      if (!bound) {
        /* a computed key, a double splat: any keyword parameter */
        for (int i = 0; i < m->nparams; i++)
          if (i == m->kwrest_idx || cf_param_is_kw(f, m, i)) { cf_flow(f, val, cf_param_el(f, mi, i)); if (i == m->kwrest_idx) cf_store(f, cf_param_el(f, mi, i), val); }
      }
    }
  }
}
/* the block of a call with a user method target: its parameters take the
   method's yield arguments, its value is what the yields answer */
static void cf_bind_block(CF *f, int mi, int blk) {
  const NodeTable *nt = f->nt;
  Compiler *c = f->c;
  if (blk < 0) return;
  Scope *m = &c->scopes[mi];
  if (nt_kind(nt, blk) == NK_BlockArgumentNode) {
    /* `&pr`: the proc's value is its body's, its parameters take anything */
    int e = nt_ref(nt, blk, "expression");
    if (e >= 0 && nt_kind(nt, e) == NK_SymbolNode) {
      const char *sym = nt_str(nt, e, "value");
      if (sym) { CFByName *b = cf_byname(f, sym); for (int i = 0; i < b->n; i++) cf_flow(f, f->ret_el[b->mi[i]], f->yval_el[mi]); }
      if (!sym || sp_streq(sym, "new") || sp_streq(sym, "allocate") || cf_opaque_name(sym)) cf_all(f, f->yval_el[mi]);
    }
    else cf_unite(f, f->yval_el[mi], e);
    return;
  }
  if (nt_kind(nt, blk) != NK_BlockNode) return;
  if (f->yval_used[mi]) cf_flow(f, blk, f->yval_el[mi]);
  int body = nt_ref(nt, blk, "body");
  const char *names[CF_YARGS];
  int plain = 1;
  int n = cf_block_params(f, blk, names, CF_YARGS, &plain);
  int opaque = (m->blk_param && m->blk_param[0]) || f->has_super[mi] || m->is_proc_form || m->is_lowered_yield;
  if (!plain || opaque) { cf_all_block_params(f, blk); return; }
  for (int i = 0; i < n; i++) if (names[i]) cf_flow(f, f->yarg_el[mi][i], cf_lv(f, body >= 0 ? body : blk, names[i]));
  const char *dn[64]; int poss[64]; unsigned char splats[64];
  int nd = cf_destructured_params(f, blk, dn, poss, splats, 64);
  for (int i = 0; i < nd; i++)
    cf_bind_destructured(f, blk, dn[i], poss[i] >= 0 && poss[i] < CF_YARGS ? f->yarg_el[mi][poss[i]] : -1, splats[i]);
}

/* ---- calls ---- */

static void cf_construct(CF *f, int v, int x, const int *argv, int argc, int blk, const char *nm);
/* a subclass of Array, Hash or String: its instances are that container */
static int cf_container_class(Compiler *c, int k) {
  if (k < 0 || k >= c->nclasses) return 0;
  ClassInfo *ci = &c->classes[k];
  return ci->ary_root || ci->ary_hash || ci->ary_str;
}

/* an iteration that drops its block's values */
static int cf_drops_block_value(const char *nm) {
  static const char *const names[] = { "each", "each_pair", "each_with_index", "each_index", "each_key",
    "each_value", "each_char", "each_byte", "each_line", "each_slice", "each_cons", "each_entry", "reverse_each",
    "times", "upto", "downto", "step", "cycle", "each_char", "each_codepoint", "each_grapheme_cluster", NULL };
  for (int i = 0; nm && names[i]; i++) if (sp_streq(nm, names[i])) return 1;
  return 0;
}
/* the builtin answer: the call's value is its receiver's, its arguments',
   its block's parameters' and its block's value (an element read, an
   iteration, a store, a pick, a copy, a conversion that hands on what it
   was given); an iteration that drops its block's values does not take
   them */
/* the methods a builtin calls back on the objects it is handed, whose
   values it may answer or build from (flatten's to_ary, sort's <=>) */
static void cf_protocol_returns(CF *f, int v, int el) {
  static const char *const names[] = { "to_ary", "to_a", "to_h", "to_hash", "to_s", "to_str", "to_proc",
    "to_path", "to_io", "to_int", "to_i", "coerce", "<=>", "==", "call", "succ", "exception", "message",
    "inspect", "hash", "eql?", "each", "dup", "clone", NULL };
  if (el < 0) return;
  int pidx = cf_set_of(f, el);
  if (pidx == CF_ALL || pidx == CF_EMPTY) return;
  const ClsSet *x = &f->pool[pidx];
  for (int i = 0; i < x->n; i++) {
    int k = x->cls[i];
    if (k < 0 || k >= f->c->nclasses) continue;
    for (int q = 0; names[q]; q++) {
      int mi = comp_method_in_chain(f->c, k, names[q], NULL);
      if (mi < 0 || cf_prelude_scope(f, mi)) continue;   /* the compiler's own answer as the builtin */
      cf_flow(f, f->ret_el[mi], v);
      if (sp_streq(names[q], "each"))
        for (int y = 0; y < CF_YARGS; y++) { cf_flow(f, f->yarg_el[mi][y], v); cf_store(f, v, f->yarg_el[mi][y]); }
    }
  }
}
/* a builtin whose value is a scalar no program class is: a comparison, a
   count or size, a conversion to a String, a number or a Symbol, a
   predicate. It keeps none of its arguments. */
static int cf_scalar_answer(const char *nm) {
  static const char *const names[] = { "==", "!=", "<", "<=", ">", ">=", "<=>", "===", "eql?", "equal?",
    "=~", "!~", "size", "length", "bytesize", "count", "hash", "to_i", "to_f", "to_s", "to_str", "to_sym",
    "inspect", NULL };
  if (!nm) return 0;
  for (int i = 0; names[i]; i++) if (sp_streq(nm, names[i])) return 1;
  size_t l = strlen(nm);
  return l > 1 && nm[l - 1] == '?';
}
/* a builtin that answers its receiver's elements (one, or a run of them)
   and keeps none of its arguments: an index or a key is only looked up */
static int cf_element_answer(const char *nm) {
  static const char *const names[] = { "[]", "first", "last", "pop", "shift", "sample", "min", "max",
    "dig", "at", NULL };
  for (int i = 0; nm && names[i]; i++) if (sp_streq(nm, names[i])) return 1;
  return 0;
}
/* Is the call plain: no block, no Symbol (a method a builtin may call by
   name), no splat? Only then is the answer by kind. A block keeps today's
   rule: its parameters take what the call's value is united with, and a
   receiver built by a method the compiler supplies (ThreadGroup's
   __groups) reaches them only that way. */
static int cf_plain_builtin_call(CF *f, const int *argv, int argc, int blk) {
  const NodeTable *nt = f->nt;
  if (blk >= 0) return 0;
  for (int i = 0; i < argc; i++) {
    NodeKind k = nt_kind(nt, argv[i]);
    if (k == NK_SymbolNode || k == NK_BlockArgumentNode || k == NK_SplatNode) return 0;
  }
  return 1;
}
static void cf_builtin_rule(CF *f, int v, int recv_el, const int *argv, int argc, int blk, const char *nm) {
  const NodeTable *nt = f->nt;
  if (cf_plain_builtin_call(f, argv, argc, blk)) {
    if (cf_scalar_answer(nm)) {
      cf_add_set(f, v, cf_bv_set(f));
      return;
    }
    if (cf_element_answer(nm)) {
      /* (a Proc's [] is its call: its set is its value's) */
      cf_load(f, recv_el, v);
      cf_flow(f, recv_el, v);
      /* dig reads through the containers it finds, to any depth */
      if (f->directed && sp_streq(nm, "dig")) cf_load(f, v, v);
      cf_add_set(f, v, cf_bv_set(f));
      cf_protocol_returns(f, v, recv_el);
      return;
    }
  }
  /* (directed) the answer may be a container of its own, of what it was
     built from or of builtin values */
  if (f->directed) { int o = cf_el_obj(f, v); if (o >= 0) cf_add_set(f, f->obj_cont[o], cf_bv_set(f)); }
  /* an operator of a builtin: a builtin value (a number, a bool, a new
     container of the operands' elements), never the operand itself; `<<`
     answers the receiver with the argument added. A user class's coerce
     can hand the operation to the program's own operator of the name. */
  if (cf_builtin_operator(nm)) {
    int shl = sp_streq(nm, "<<");
    cf_add_set(f, v, cf_bv_set(f));
    if (shl) cf_flow(f, recv_el, v);
    cf_share(f, v, recv_el);
    for (int i = 0; i < argc; i++) {
      NodeKind k = nt_kind(nt, argv[i]);
      if (k == NK_BlockArgumentNode || k == NK_SymbolNode) continue;
      int a = k == NK_SplatNode ? nt_ref(nt, argv[i], "expression") : argv[i];
      cf_share(f, v, a);
      if (shl) cf_store(f, recv_el, a);
      cf_protocol_returns(f, v, a);
    }
    if (cf_byname(f, "coerce")->n) {
      CFByName *b = cf_byname(f, nm);
      for (int i = 0; i < b->n; i++) if (!cf_prelude_scope(f, b->mi[i])) cf_flow(f, f->ret_el[b->mi[i]], v);
    }
    if (blk >= 0 && nt_kind(nt, blk) == NK_BlockNode) cf_all_block_params(f, blk);
    return;
  }
  /* any other: the value may be the receiver, its contents or an argument,
     and shares the receiver's contents; an argument may be stored into the
     receiver */
  cf_flow(f, recv_el, v);
  cf_load(f, recv_el, v);
  if (f->directed && sp_streq(nm, "dig")) cf_load(f, v, v);   /* to any depth */
  cf_share(f, v, recv_el);
  cf_add_set(f, v, cf_bv_set(f));
  cf_protocol_returns(f, v, recv_el);
  for (int i = 0; i < argc; i++)
    if (nt_kind(nt, argv[i]) != NK_BlockArgumentNode && nt_kind(nt, argv[i]) != NK_SymbolNode)
      cf_protocol_returns(f, v, nt_kind(nt, argv[i]) == NK_SplatNode ? nt_ref(nt, argv[i], "expression") : argv[i]);
  for (int i = 0; i < argc; i++) {
    NodeKind k = nt_kind(nt, argv[i]);
    if (k == NK_BlockArgumentNode) {
      int e = nt_ref(nt, argv[i], "expression");
      if (e >= 0 && nt_kind(nt, e) == NK_SymbolNode) {
        const char *sym = nt_str(nt, e, "value");
        if (!sym || sp_streq(sym, "new") || sp_streq(sym, "allocate") || cf_opaque_name(sym)) cf_all(f, v);
        else { CFByName *b = cf_byname(f, sym); for (int q = 0; q < b->n; q++) { cf_flow(f, f->ret_el[b->mi[q]], v); cf_store(f, v, f->ret_el[b->mi[q]]); } }
      }
      else cf_unite(f, v, e);
      continue;
    }
    if (k == NK_SymbolNode) {
      /* `to_enum(:m)`: the Enumerator yields what m yields, so its values
         are m's yield arguments (as each's are, cf_protocol_returns) */
      if (i == 0 && (sp_streq(nm, "to_enum") || sp_streq(nm, "enum_for"))) {
        CFByName *b = cf_byname(f, nt_str(nt, argv[i], "value"));
        for (int q = 0; q < b->n; q++)
          for (int y = 0; y < CF_YARGS; y++) { cf_flow(f, f->yarg_el[b->mi[q]][y], v); cf_store(f, v, f->yarg_el[b->mi[q]][y]); }
      }
      continue;
    }
    int a = k == NK_SplatNode ? nt_ref(nt, argv[i], "expression") : argv[i];
    cf_flow(f, a, v);
    cf_store(f, recv_el, a);
    /* (and its elements: `concat`, `merge`), through the answer's own
       container in directed mode */
    if (f->directed) { int o = cf_el_obj(f, v); cf_load(f, a, f->obj_cont[o]); cf_store(f, recv_el, f->obj_cont[o]); }
    else cf_share(f, recv_el, a);
  }
  if (blk >= 0 && nt_kind(nt, blk) == NK_BlockNode) {
    if (!cf_drops_block_value(nm)) { cf_flow(f, blk, v); cf_store(f, v, blk); }
    int body = nt_ref(nt, blk, "body");
    const char *names[64];
    int n = cf_all_param_names(f, blk, names, 64);
    for (int i = 0; i < n; i++) {
      int pe = cf_lv(f, body >= 0 ? body : blk, names[i]);
      if (!f->directed) { cf_unite(f, v, pe); continue; }
      /* an element, the receiver, an argument (a memo, an initial value),
         the block's own value (an accumulator) */
      cf_load(f, recv_el, pe);
      cf_flow(f, recv_el, pe);
      cf_flow(f, blk, pe);
      for (int q = 0; q < argc; q++) {
        NodeKind ak = nt_kind(nt, argv[q]);
        if (ak == NK_BlockArgumentNode || ak == NK_SymbolNode) continue;
        cf_flow(f, ak == NK_SplatNode ? nt_ref(nt, argv[q], "expression") : argv[q], pe);
      }
    }
    /* a destructuring parameter takes the same as a whole, through an
       element of its own (one per such parameter), and its names are
       bound from that (cf_bind_destructured) */
    { const char *dn[64]; int poss[64], dpe[64]; unsigned char splats[64];
      int nd = cf_destructured_params(f, blk, dn, poss, splats, 64);
      for (int i = 0; i < nd; i++) {
        int j = 0;
        while (j < i && poss[j] != poss[i]) j++;
        if (j < i) dpe[i] = dpe[j];
        else {
          char tag[24]; snprintf(tag, sizeof tag, "#dp%d", poss[i]);
          int pe = dpe[i] = cf_entry(f, -(blk + 2), tag);   /* one per parameter, held across the rounds */
          if (!f->directed) cf_unite(f, v, pe);
          else {
            cf_load(f, recv_el, pe);
            cf_flow(f, recv_el, pe);
            cf_flow(f, blk, pe);
            for (int q = 0; q < argc; q++) {
              NodeKind ak = nt_kind(nt, argv[q]);
              if (ak == NK_BlockArgumentNode || ak == NK_SymbolNode) continue;
              cf_flow(f, ak == NK_SplatNode ? nt_ref(nt, argv[q], "expression") : argv[q], pe);
            }
          }
        }
        cf_bind_destructured(f, blk, dn[i], dpe[i], splats[i]);
      } }
  }
  else if (blk >= 0 && nt_kind(nt, blk) == NK_BlockArgumentNode) {
    int e = nt_ref(nt, blk, "expression");
    if (e >= 0 && nt_kind(nt, e) == NK_SymbolNode) {
      const char *sym = nt_str(nt, e, "value");
      if (!sym || sp_streq(sym, "new") || sp_streq(sym, "allocate") || cf_opaque_name(sym)) cf_all(f, v);
      else { CFByName *b = cf_byname(f, sym); for (int q = 0; q < b->n; q++) { cf_flow(f, f->ret_el[b->mi[q]], v); cf_store(f, v, f->ret_el[b->mi[q]]); } }
    }
    else cf_unite(f, v, e);
  }
  (void)nm;
}

/* a user method target: its value, its parameters, its block; 0 for a
   method the compiler supplies, which answers as the builtin it is */
static int cf_user_target(CF *f, int v, int mi, const int *argv, int argc, int blk) {
  if (mi < 0) return 0;
  if (cf_prelude_scope(f, mi)) {
    /* the compiler's own answer, which the caller takes as the builtin's;
       (directed) its body runs too, and what it hands back (state a
       class keeps: ThreadGroup's __groups) is the same object at each
       call, which the builtin's answer, one per call, is not */
    if (f->directed) {
      if (v >= 0) cf_flow(f, f->ret_el[mi], v);
      cf_bind_args(f, mi, argv, argc);
      cf_bind_block(f, mi, blk);
    }
    return 0;
  }
  if (v >= 0) cf_flow(f, f->ret_el[mi], v);
  cf_bind_args(f, mi, argv, argc);
  cf_bind_block(f, mi, blk);
  return 1;
}

/* `X.new(...)`: an instance of the user class X, initialized */
static void cf_construct(CF *f, int v, int x, const int *argv, int argc, int blk, const char *nm) {
  Compiler *c = f->c;
  const NodeTable *nt = f->nt;
  cf_add_set(f, v, f->own[x]);
  /* (directed) an instance of a subclass of Array, Hash or String is a
     container whose contents the walk does not follow (its own methods
     fill it through self) */
  if (f->directed && cf_container_class(c, x)) cf_ptop_set(f, v);
  ClassInfo *k = &c->classes[x];
  int cn = sp_streq(nm, "new") ? comp_cmethod_in_chain(c, x, "new", NULL) : -1;
  if (cn >= 0 && cf_user_target(f, v, cn, argv, argc, blk)) return;
  if (sp_streq(nm, "allocate")) return;
  int init = comp_method_in_chain(c, x, "initialize", NULL);
  if (init >= 0) { cf_user_target(f, -1, init, argv, argc, blk); return; }
  if (k->is_struct || k->is_data) {
    /* the members, in order, or by keyword */
    int kwh = -1, p = 0;
    for (int i = 0; i < argc; i++) {
      NodeKind ak = nt_kind(nt, argv[i]);
      if (ak == NK_KeywordHashNode) { kwh = argv[i]; continue; }
      if (ak == NK_BlockArgumentNode) continue;
      if (ak == NK_SplatNode) {
        for (int r = 0; r < k->nreaders; r++) { char ivn[256]; snprintf(ivn, sizeof ivn, "@%s", k->readers[r]); cf_flow(f, nt_ref(nt, argv[i], "expression"), cf_entry(f, f->fam[x], ivn)); }
        continue;
      }
      if (p < k->nreaders) { char ivn[256]; snprintf(ivn, sizeof ivn, "@%s", k->readers[p]); cf_flow(f, argv[i], cf_entry(f, f->fam[x], ivn)); }
      p++;
    }
    if (kwh >= 0) {
      int en = 0; const int *els = nt_arr(nt, kwh, "elements", &en);
      for (int e = 0; e < en; e++) {
        int key = nt_kind(nt, els[e]) == NK_AssocNode ? nt_ref(nt, els[e], "key") : -1;
        const char *kn = key >= 0 && nt_kind(nt, key) == NK_SymbolNode ? nt_str(nt, key, "value") : NULL;
        int val = nt_ref(nt, els[e], "value");
        if (kn) { char ivn[256]; snprintf(ivn, sizeof ivn, "@%s", kn); cf_flow(f, val, cf_entry(f, f->fam[x], ivn)); }
        else for (int r = 0; r < k->nreaders; r++) { char ivn[256]; snprintf(ivn, sizeof ivn, "@%s", k->readers[r]); cf_flow(f, val, cf_entry(f, f->fam[x], ivn)); }
      }
    }
  }
  if (blk >= 0 && nt_kind(nt, blk) == NK_BlockNode) cf_all_block_params(f, blk);
}

/* the call on a receiver whose classes are known (set pidx, not every
   class): each class's method, reader or writer; the builtin answer where
   one has none */
/* The value of a call on an instance of a native class (a `native_struct`
   with `native_method` bindings): the binding's declared answer, a builtin
   value for a String, a number, a bool or nil (`:string`, `:nstring`,
   `:int`, ...), the receiver itself for `:self`, anything for `:any`. A
   name no binding takes answers as Object's method would when it is one
   whose answer is a builtin (`nil?`, `==`, `to_s`), else anything. */
static void cf_native_answer(CF *f, int v, int recv_el, int k, const char *nm, int argc) {
  Compiler *c = f->c;
  int m = comp_native_method_find(c, k, nm, argc, 0);
  if (m < 0) {
    if (cf_scalar_answer(nm)) cf_add_set(f, v, cf_bv_set(f));
    else cf_all(f, v);
    return;
  }
  const char *ret = c->native_methods[m].ret;
  if (!ret || !*ret) { cf_add_set(f, v, cf_bv_set(f)); return; }   /* no value: nil */
  if (sp_streq(ret, "self")) { cf_flow(f, recv_el, v); return; }
  TyKind t = native_spec_to_ty(ret);
  if (sp_streq(ret, "string?") || sp_streq(ret, "int?") || sp_streq(ret, "float?") ||
      (t != TY_POLY && t != TY_UNKNOWN)) { cf_add_set(f, v, cf_bv_set(f)); return; }
  cf_all(f, v);
}

static void cf_call_known(CF *f, int v, int pidx, int recv_el, const char *nm, const int *argv, int argc, int blk) {
  Compiler *c = f->c;
  const ClsSet *s = &f->pool[pidx];
  int builtin = pidx == CF_EMPTY || s->bv;
  char base[256] = "";
  int is_w = setter_base_name(nm, base, sizeof base);
  for (int i = 0; i < s->n; i++) {
    int k = s->cls[i];
    if (k >= c->nclasses) {
      /* the Class object: a construction, a class method, else Class's own */
      int kc = k - c->nclasses;
      if (kc < 0 || kc >= c->nclasses) { builtin = 1; continue; }
      if (sp_streq(nm, "new") || sp_streq(nm, "allocate") ||
          ((c->classes[kc].is_struct || c->classes[kc].is_data) && sp_streq(nm, "[]"))) {
        cf_construct(f, v, kc, argv, argc, blk, nm);
        continue;
      }
      int cm = comp_cmethod_in_chain(c, kc, nm, NULL);
      if (cm >= 0 && cf_user_target(f, v, cm, argv, argc, blk)) continue;
      if (cm < 0 && cf_sg_access(f, v, kc, nm, argv, argc)) continue;
      if (cm < 0 && f->mod[kc]) { int mm = comp_method_in_chain(c, kc, nm, NULL); if (mm >= 0 && cf_user_target(f, v, mm, argv, argc, blk)) continue; }
      if (cf_class_has_natives(f, kc)) { cf_all(f, v); continue; }
      builtin = 1;
      continue;
    }
    if (k < 0) { builtin = 1; continue; }
    int mi = comp_method_in_chain(c, k, nm, NULL);
    if (mi >= 0) { if (!cf_user_target(f, v, mi, argv, argc, blk)) builtin = 1; continue; }
    if (comp_reader_in_chain(c, k, nm, NULL)) {
      /* the reader an alias names reads its own ivar (`alias loc location`) */
      char ivn[256]; snprintf(ivn, sizeof ivn, "@%s", comp_resolve_alias(c, k, nm));
      cf_flow(f, cf_entry(f, f->fam[k], ivn), v);
      continue;
    }
    if (is_w && comp_writer_in_chain(c, k, base, NULL)) {
      char ivn[sizeof base + 1]; snprintf(ivn, sizeof ivn, "@%s", base);
      for (int a = 0; a < argc; a++) { cf_flow(f, argv[a], cf_entry(f, f->fam[k], ivn)); cf_flow(f, argv[a], v); }
      continue;
    }
    int tl = comp_method_index(c, nm);
    if (tl >= 0 && cf_user_target(f, v, tl, argv, argc, blk)) continue;
    if (comp_method_in_chain(c, k, "method_missing", NULL) >= 0) {
      cf_all(f, v);
      for (int a = 0; a < argc; a++) cf_all(f, argv[a]);
      if (blk >= 0 && nt_kind(f->nt, blk) == NK_BlockNode) cf_all_block_params(f, blk);
      continue;
    }
    /* a native binding of the class: what its declaration says it answers */
    if (cf_class_has_natives(f, k)) {
      cf_native_answer(f, v, recv_el, k, nm, argc);
      if (blk >= 0 && nt_kind(f->nt, blk) == NK_BlockNode) cf_all_block_params(f, blk);
      continue;
    }
    /* a builtin method of the object: a copy, a conversion, a Struct's
       members, Enumerable over the class's own each */
    builtin = 1;
    ClassInfo *ci = &c->classes[k];
    if (ci->is_struct || ci->is_data)
      for (int r = 0; r < ci->nreaders; r++) {
        char ivn[256]; snprintf(ivn, sizeof ivn, "@%s", ci->readers[r]);
        int me = cf_entry(f, f->fam[k], ivn);
        cf_flow(f, me, v); cf_store(f, recv_el, me);
      }
    int each = comp_method_in_chain(c, k, "each", NULL);
    if (each >= 0) for (int y = 0; y < CF_YARGS; y++) { cf_flow(f, f->yarg_el[each][y], v); cf_store(f, recv_el, f->yarg_el[each][y]); }
  }
  if (builtin) {
    /* Deferred until the classes have settled: the builtin answer unifies
       the receiver with the call's value and arguments, which a receiver
       whose class is known only later (its write is a later node, or a
       method's value) would then share with that class's methods. */
    if (!f->phase) { f->pending++; return; }
    if (argc > 0 && (sp_streq(nm, "resume") || sp_streq(nm, "transfer"))) cf_all(f, f->fiber_ch);
    if (cf_opaque_name(nm) || sp_streq(nm, "new") || sp_streq(nm, "allocate")) {
      cf_all(f, v);
      for (int a = 0; a < argc; a++) cf_all(f, argv[a]);
      if (blk >= 0 && nt_kind(f->nt, blk) == NK_BlockNode) cf_all_block_params(f, blk);
      if (sp_streq(nm, "new")) { CFByName *b = cf_byname(f, "initialize"); for (int q = 0; q < b->n; q++) cf_bind_args(f, b->mi[q], argv, argc); }
      return;
    }
    /* `.class`: the Class objects of the receiver's classes */
    if (sp_streq(nm, "class") && argc == 0) cf_add_set(f, v, cf_classvals_of(f, pidx));
    /* a method the program adds to a runtime class or module it reopens
       answers for the runtime's values too (`class Object; def tagged`,
       `42.tagged`) */
    for (int i = 0; i < f->nopen; i++) {
      int mi = comp_method_in_chain(c, f->open[i], nm, NULL);
      if (mi >= 0) cf_user_target(f, v, mi, argv, argc, blk);
    }
    cf_builtin_rule(f, v, recv_el, argv, argc, blk, nm);
  }
}

/* the call on a receiver that can be anything: every method of the name
   takes the arguments and the block; the value is anything */
static void cf_call_any(CF *f, int v, const char *nm, const int *argv, int argc, int blk) {
  Compiler *c = f->c;
  cf_all(f, v);
  if (argc > 0 && (sp_streq(nm, "resume") || sp_streq(nm, "transfer"))) cf_all(f, f->fiber_ch);
  CFByName *b = cf_byname(f, nm);
  for (int i = 0; i < b->n; i++) { cf_bind_args(f, b->mi[i], argv, argc); cf_bind_block(f, b->mi[i], blk); }
  for (int i = 0; i < b->ncm; i++) { cf_bind_args(f, b->cmi[i], argv, argc); cf_bind_block(f, b->cmi[i], blk); }
  for (int i = 0; i < b->nwr; i++) {
    char ivn[256]; snprintf(ivn, sizeof ivn, "@%.*s", (int)strlen(nm) - 1, nm);
    for (int a = 0; a < argc; a++) cf_flow(f, argv[a], cf_entry(f, f->fam[b->wr[i]], ivn));
  }
  if (sp_streq(nm, "new")) { CFByName *ini = cf_byname(f, "initialize"); for (int q = 0; q < ini->n; q++) cf_bind_args(f, ini->mi[q], argv, argc); }
  /* the block's parameters and the arguments may go anywhere */
  if (blk >= 0 && nt_kind(f->nt, blk) == NK_BlockNode) { cf_all_block_params(f, blk); cf_flow(f, blk, v); }
  for (int a = 0; a < argc; a++) {
    NodeKind k = nt_kind(f->nt, argv[a]);
    if (k == NK_BlockArgumentNode || k == NK_SymbolNode) continue;
    int an = k == NK_SplatNode ? nt_ref(f->nt, argv[a], "expression") : argv[a];
    /* (directed) code the walk does not see can store anything into an
       argument, which changes its contents, not the classes the argument
       holds */
    if (f->directed) cf_escape(f, an);
    else cf_all(f, an);
  }
  (void)c;
}

static void cf_send_writers(CF *f, int v, int r) {
  Compiler *c = f->c;
  Scope *sc = &c->scopes[cf_scope_of(f, v)];
  int ks = r >= 0 ? cf_set_of(f, r) : sc->def_node >= 0 && sc->class_id >= 0 ? f->desc[sc->class_id] : CF_EMPTY;
  const ClsSet *s = &f->pool[ks];
  for (int k = 0; k < c->nclasses; k++) {
    int in = s->all;
    for (int i = 0; i < s->n && !in; i++) in = s->cls[i] == k;
    for (int x = in ? k : -1; x >= 0; x = c->classes[x].parent)
      for (int w = 0; w < c->classes[x].nwriters; w++) {
        char ivn[256];
        snprintf(ivn, sizeof ivn, "@%s", c->classes[x].writers[w]);
        cf_all(f, cf_entry(f, f->fam[k], ivn));
      }
  }
}

static void cf_call(CF *f, int v) {
  Compiler *c = f->c;
  const NodeTable *nt = f->nt;
  const char *nm = nt_str(nt, v, "name");
  int r = nt_ref(nt, v, "receiver");
  int a = nt_ref(nt, v, "arguments"), argc = 0;
  const int *argv = a >= 0 ? nt_arr(nt, a, "arguments", &argc) : NULL;
  int blk = nt_ref(nt, v, "block");
  if (!nm) { cf_all(f, v); return; }
  /* `send(:m, a, b)` with the name a literal is the call `m(a, b)` */
  if (argc >= 1 && (sp_streq(nm, "send") || sp_streq(nm, "__send__") || sp_streq(nm, "public_send"))) {
    NodeKind k0 = nt_kind(nt, argv[0]);
    const char *lit = k0 == NK_SymbolNode ? nt_str(nt, argv[0], "value") : k0 == NK_StringNode ? nt_str(nt, argv[0], "content") : NULL;
    if (lit) { nm = lit; argv++; argc--; }
  }
  if (cf_opaque_name(nm)) {
    cf_all(f, v);
    for (int i = 0; i < argc; i++) cf_all(f, argv[i]);
    if (blk >= 0 && nt_kind(nt, blk) == NK_BlockNode) { cf_all_block_params(f, blk); cf_all(f, blk); }
    if (argc >= 2 && (sp_streq(nm, "send") || sp_streq(nm, "__send__") || sp_streq(nm, "public_send")) &&
        nt_kind(nt, argv[0]) != NK_SymbolNode && nt_kind(nt, argv[0]) != NK_StringNode)
      cf_send_writers(f, v, r);
    return;
  }
  /* an alias that captured a builtin (`alias old_dup dup`, #8914) calls the
     builtin: not the method the class defines of the name after it, whose
     answer is not the receiver */
  if (nt_int(nt, v, "builtin_only", 0)) {
    int recv_el = r;
    if (r < 0) {
      int ik = cf_inst_class(f, cf_scope_of(f, v));
      recv_el = ik >= 0 && !cf_selfless_fn(nm) ? f->self_el[ik] : -1;
    }
    cf_builtin_rule(f, v, recv_el, argv, argc, blk, nm);
    return;
  }
  if (r < 0) {
    /* a call on self: the method of self's class, or of a subclass whose
       instance runs this code; else the top-level def; else Kernel's */
    int si = cf_scope_of(f, v);
    Scope *s = &c->scopes[si];
    int found = 0;
    if (s->def_node >= 0 && s->class_id >= 0) {
      const ClsSet *ds = &f->pool[f->desc[s->class_id]];
      if (ds->all) { cf_call_any(f, v, nm, argv, argc, blk); return; }
      /* `new` or `allocate` in a class method: an instance of the class
         the method runs for, which a subclass's call makes its own */
      if (s->is_cmethod && (sp_streq(nm, "new") || sp_streq(nm, "allocate")) &&
          comp_cmethod_in_chain(c, s->class_id, nm, NULL) < 0) {
        cf_add_set(f, v, f->desc[s->class_id]);
        /* each class as `X.new` builds it: its initialize, or a Struct's
           or Data's members, which have none */
        for (int i = 0; i < ds->n; i++) {
          cf_construct(f, -1, ds->cls[i], argv, argc, blk, nm);
          if (f->directed && cf_container_class(c, ds->cls[i])) cf_ptop_set(f, v);
        }
        return;
      }
      if (s->is_cmethod) {
        int cm = comp_cmethod_in_chain(c, s->class_id, nm, NULL);
        if (cm >= 0 && cf_user_target(f, v, cm, argv, argc, blk)) found = 1;
        for (int i = 0; i < ds->n && !found; i++) {
          int cm2 = comp_cmethod_in_chain(c, ds->cls[i], nm, NULL);
          if (cm2 >= 0 && cf_user_target(f, v, cm2, argv, argc, blk)) found = 1;
        }
        /* a singleton accessor of the class self is, or of a subclass */
        if (!found && cf_sg_access(f, v, s->class_id, nm, argv, argc)) found = 1;
        for (int i = 0; i < ds->n; i++) if (ds->cls[i] != s->class_id && cf_sg_access(f, v, ds->cls[i], nm, argv, argc)) found = 1;
      }
      else {
        for (int i = 0; i < ds->n; i++) {
          int mi = comp_method_in_chain(c, ds->cls[i], nm, NULL);
          if (mi >= 0) { if (cf_user_target(f, v, mi, argv, argc, blk)) found = 1; continue; }
          if (comp_reader_in_chain(c, ds->cls[i], nm, NULL)) {
            char ivn[256]; snprintf(ivn, sizeof ivn, "@%s", comp_resolve_alias(c, ds->cls[i], nm));
            cf_flow(f, cf_entry(f, f->fam[ds->cls[i]], ivn), v);
            found = 1;
          }
        }
        if (!found) {
          int mi = comp_method_in_chain(c, s->class_id, nm, NULL);
          if (mi >= 0 && cf_user_target(f, v, mi, argv, argc, blk)) found = 1;
        }
        if (!found && f->has_mm) {
          for (int i = 0; i < ds->n && !found; i++)
            if (comp_method_in_chain(c, ds->cls[i], "method_missing", NULL) >= 0) { cf_call_any(f, v, nm, argv, argc, blk); return; }
        }
      }
    }
    else if (v < f->nnodes && c->node_cbody && c->node_cbody[v] >= 0) {
      /* a class body: the class's own class methods (`attr_accessor`,
         `include` are builtins of Module); a bare `new` is the class's */
      int cb = c->node_cbody[v];
      if (sp_streq(nm, "new") || sp_streq(nm, "allocate")) { cf_construct(f, v, cb, argv, argc, blk, nm); return; }
      int cm = comp_cmethod_in_chain(c, cb, nm, NULL);
      if (cm >= 0 && cf_user_target(f, v, cm, argv, argc, blk)) found = 1;
    }
    if (!found) {
      int tl = comp_method_index(c, nm);
      if (tl >= 0 && cf_user_target(f, v, tl, argv, argc, blk)) found = 1;
    }
    /* a module included at top level is Object's, so its method answers a
       bare call no class or top-level def did */
    for (int k = 0; k < c->ntoplevel_includes && !found; k++) {
      int mi = comp_method_in_chain(c, c->toplevel_includes[k], nm, NULL);
      if (mi >= 0 && cf_user_target(f, v, mi, argv, argc, blk)) found = 1;
    }
    if (found) return;
    /* a native binding of the class (an ffi_func): anything */
    if (s->def_node >= 0 && s->class_id >= 0) {
      const ClsSet *ds = &f->pool[f->desc[s->class_id]];
      int nat = cf_class_has_natives(f, s->class_id);
      for (int i = 0; i < ds->n && !nat; i++) nat = cf_class_has_natives(f, ds->cls[i]);
      if (nat) {
        cf_all(f, v);
        if (blk >= 0 && nt_kind(nt, blk) == NK_BlockNode) cf_all_block_params(f, blk);
        return;
      }
    }
    if (cf_owner_block(f, v, 0) >= 0) {
      CFByName *b = cf_byname(f, nm);
      if (b->n || b->ncm || b->nrd || b->nwr) { cf_call_any(f, v, nm, argv, argc, blk); return; }
    }
    /* Kernel: a conversion, an iteration, `lambda`, `proc`, `loop`, `raise`
       hand on what they are given; `new` has no class here */
    if (sp_streq(nm, "lambda") || sp_streq(nm, "proc") || sp_streq(nm, "define_method")) {
      if (blk >= 0 && nt_kind(nt, blk) == NK_BlockNode) cf_all_block_params(f, blk);
    }
    /* Kernel's conversions answer their kind whatever they are handed:
       Integer(x) an Integer (to_int / to_i must answer one, else it
       raises), Float, String, Rational and Complex likewise; Array(x) and
       Hash(x) a container of x, its elements, or what its to_ary / to_a /
       to_hash answers */
    if (cf_kernel_conversion(nm) && blk < 0) {
      cf_add_set(f, v, cf_bv_set(f));
      if (sp_streq(nm, "Array") || sp_streq(nm, "Hash")) {
        /* (unified) one element for the container and what it holds */
        int cont = v;
        if (f->directed) { int o = cf_el_obj(f, v); cont = f->obj_cont[o]; }   /* (cf_el_obj may move obj_cont) */
        for (int i = 0; i < argc; i++) {
          NodeKind ak = nt_kind(nt, argv[i]);
          if (ak == NK_BlockArgumentNode || ak == NK_KeywordHashNode) continue;
          int a = ak == NK_SplatNode ? nt_ref(nt, argv[i], "expression") : argv[i];
          cf_flow(f, a, cont);
          cf_load(f, a, cont);
          static const char *const convs[] = { "to_ary", "to_a", "to_hash", "to_h", NULL };
          for (int q = 0; convs[q]; q++) {
            CFByName *b = cf_byname(f, convs[q]);
            for (int j = 0; j < b->n; j++) if (!cf_prelude_scope(f, b->mi[j])) cf_load(f, f->ret_el[b->mi[j]], cont);
          }
        }
      }
      return;
    }
    /* self is the receiver (`def seal = freeze` answers self, a bare
       `each` in an Array subclass iterates self) */
    int ik = cf_inst_class(f, si);
    cf_builtin_rule(f, v, ik >= 0 && !cf_selfless_fn(nm) ? f->self_el[ik] : -1, argv, argc, blk, nm);
    return;
  }
  int x = cf_is_class_const(f, r);
  if (x >= 0) {
    ClassInfo *k = &c->classes[x];
    if (sp_streq(nm, "new") || sp_streq(nm, "allocate") || ((k->is_struct || k->is_data) && sp_streq(nm, "[]"))) {
      cf_construct(f, v, x, argv, argc, blk, nm);
      return;
    }
    int cm = comp_cmethod_in_chain(c, x, nm, NULL);
    if (cm >= 0 && cf_user_target(f, v, cm, argv, argc, blk)) return;
    if (cm < 0 && cf_sg_access(f, v, x, nm, argv, argc)) return;
    if (cm < 0 && f->mod[x]) {
      /* a module function */
      int mi = comp_method_in_chain(c, x, nm, NULL);
      if (mi >= 0 && cf_user_target(f, v, mi, argv, argc, blk)) return;
    }
    /* a native binding of the class or module (an ffi_func, a Fiddle
       extern): its value is anything */
    if (cf_class_has_natives(f, x)) {
      cf_all(f, v);
      if (blk >= 0 && nt_kind(nt, blk) == NK_BlockNode) cf_all_block_params(f, blk);
      return;
    }
    /* a method of Class or Module: nothing of the program's own comes out,
       except through a block */
    if (blk >= 0 && nt_kind(nt, blk) == NK_BlockNode) cf_all_block_params(f, blk);
    cf_builtin_rule(f, v, -1, argv, argc, blk, nm);
    return;
  }
  NodeKind rk = nt_kind(nt, r);
  if (rk == NK_ConstantReadNode || rk == NK_ConstantPathNode) {
    const char *cn = nt_str(nt, r, "name");
    const char *key = cf_const_key(cn);
    if (cn && (cf_poison_const(cn) || (key && cf_poison_const(key)))) {
      /* its value, and its block's parameters, come from anywhere; its
         arguments are only stored (a Fiber's yield hands them to a resume,
         whose value is one of these). Fiber.yield answers what a resume
         passes: the channel, which a resume with arguments makes anything
         (the enumerators the compiler makes resume with none). */
      if (key && sp_streq(key, "Fiber") && sp_streq(nm, "yield")) { cf_flow(f, f->fiber_ch, v); return; }
      cf_all(f, v);
      if (blk >= 0 && nt_kind(nt, blk) == NK_BlockNode) { cf_all_block_params(f, blk); cf_all(f, blk); }
      return;
    }
    /* a constant holding a value of the program's own (`REG = Registry.new`)
       is a receiver like any other; a builtin class or module answers
       builtin values, built from the arguments (`Set.new(list)`,
       `Array.new(n, x)`, `Hash.new { }`), its block's parameters taking
       anything (`Proc.new { |x| }`, `Hash.new { |h, k| }`) */
    int prog = cf_entry_has(f, CF_K_CONSTW, key);
    int ce = prog ? cf_entry(f, CF_K_CONST, key) : -1;
    int pidx = prog ? cf_set_of(f, ce) : CF_EMPTY;
    if (pidx != CF_EMPTY) {
      if (pidx == CF_ALL) { cf_call_any(f, v, nm, argv, argc, blk); return; }
      cf_call_known(f, v, pidx, ce, nm, argv, argc, blk);
      return;
    }
    /* a Proc's parameters take what its calls pass; an Enumerator's yielder,
       a Hash's default block's hash and the rest are the builtin's own */
    if (blk >= 0 && nt_kind(nt, blk) == NK_BlockNode && sp_streq(nm, "new") && key && sp_streq(key, "Proc")) cf_all_block_params(f, blk);
    cf_builtin_rule(f, v, ce, argv, argc, blk, nm);
    return;
  }
  if (rk == NK_SelfNode && (sp_streq(nm, "new") || sp_streq(nm, "allocate"))) {
    /* `self.new` in a class method: as the bare call above */
    int si = cf_scope_of(f, v);
    Scope *s = &c->scopes[si];
    if (s->def_node >= 0 && s->is_cmethod && s->class_id >= 0 && comp_cmethod_in_chain(c, s->class_id, nm, NULL) < 0) {
      const ClsSet *ds = &f->pool[f->desc[s->class_id]];
      cf_add_set(f, v, f->desc[s->class_id]);
      if (ds->all) { for (int i = 0; i < argc; i++) cf_all(f, argv[i]); return; }
      for (int i = 0; i < ds->n; i++) cf_construct(f, -1, ds->cls[i], argv, argc, blk, nm);
      return;
    }
  }
  int recv_el = r;
  int pidx = cf_set_of(f, recv_el);
  /* (why: the value is every class because the receiver is) */
  if (pidx == CF_ALL && f->directed && f->orig && v >= 0 && !f->orig[v] && f->set[v] != CF_ALL) f->orig[v] = f->orig[recv_el];
  if (pidx == CF_ALL) {
    /* (directed) the method may be a builtin's that stores its arguments
       into the receiver: into each container the receiver is known to hold */
    if (f->directed)
      for (int a = 0; a < argc; a++) {
        NodeKind ak = nt_kind(nt, argv[a]);
        if (ak == NK_BlockArgumentNode || ak == NK_SymbolNode) continue;
        cf_store(f, recv_el, ak == NK_SplatNode ? nt_ref(nt, argv[a], "expression") : argv[a]);
      }
    cf_call_any(f, v, nm, argv, argc, blk);
    return;
  }
  cf_call_known(f, v, pidx, recv_el, nm, argv, argc, blk);
}

/* an attribute or index write through a call: `o.x ||= v`, `h[k] += v`
   (`o.x += v` is a read and a write by then). The node's value is the
   read, the right side and an operator's answer; that is what the write
   stores. */
static void cf_op_answer(CF *f, int v, const char *op, int val) {
  if (!op) return;
  int pidx = cf_set_of(f, v), argv[1] = { val };
  if (pidx == CF_ALL) cf_call_any(f, v, op, argv, 1, -1);
  else cf_call_known(f, v, pidx, v, op, argv, 1, -1);
}
static void cf_call_write(CF *f, int v) {
  const NodeTable *nt = f->nt;
  NodeKind k = nt_kind(nt, v);
  int r = nt_ref(nt, v, "receiver");
  int val = nt_ref(nt, v, "value");
  const char *op = k == NK_IndexOperatorWriteNode ? nt_str(nt, v, "binary_operator") : NULL;
  cf_unite(f, v, val);
  if (r < 0) { cf_all(f, v); return; }
  int argv[33], argc = 0;
  if (k == NK_IndexAndWriteNode || k == NK_IndexOrWriteNode || k == NK_IndexOperatorWriteNode) {
    int a = nt_ref(nt, v, "arguments"), an = 0;
    const int *av = a >= 0 ? nt_arr(nt, a, "arguments", &an) : NULL;
    for (int i = 0; i < an && argc < 32; i++) argv[argc++] = av[i];
    int pidx = cf_set_of(f, r);
    if (pidx == CF_ALL) cf_call_any(f, v, "[]", argv, argc, -1);
    else cf_call_known(f, v, pidx, r, "[]", argv, argc, -1);
    cf_op_answer(f, v, op, val);
    argv[argc++] = v;
    if (pidx == CF_ALL) cf_call_any(f, v, "[]=", argv, argc, -1);
    else cf_call_known(f, v, pidx, r, "[]=", argv, argc, -1);
    return;
  }
  /* the parser keeps the reader's name; the writer's is it with `=` */
  const char *rn = nt_str(nt, v, "name");
  char wn[256];
  if (!rn || strlen(rn) + 2 > sizeof wn) { cf_all(f, v); return; }
  snprintf(wn, sizeof wn, "%s=", rn);
  int x = cf_is_class_const(f, r);
  if (x >= 0) {
    int cm = comp_cmethod_in_chain(f->c, x, rn, NULL);
    if (cm >= 0) cf_user_target(f, v, cm, NULL, 0, -1);
    else cf_sg_access(f, v, x, rn, NULL, 0);
    cf_op_answer(f, v, op, val);
    argv[argc++] = v;
    cm = comp_cmethod_in_chain(f->c, x, wn, NULL);
    if (cm >= 0) cf_user_target(f, v, cm, argv, argc, -1);
    else cf_sg_access(f, v, x, wn, argv, argc);
    return;
  }
  int pidx = cf_set_of(f, r);
  if (pidx == CF_ALL) { cf_call_any(f, v, rn, NULL, 0, -1); cf_op_answer(f, v, op, val); argv[argc++] = v; cf_call_any(f, v, wn, argv, argc, -1); return; }
  cf_call_known(f, v, pidx, r, rn, NULL, 0, -1);
  cf_op_answer(f, v, op, val);
  argv[argc++] = v;
  cf_call_known(f, v, pidx, r, wn, argv, argc, -1);
}

/* ---- the node walk ---- */

static void cf_rescue(CF *f, int v) {
  const NodeTable *nt = f->nt;
  int ref = nt_ref(nt, v, "reference");
  if (ref < 0) return;
  int el = -1;
  NodeKind rk = nt_kind(nt, ref);
  if (rk == NK_LocalVariableTargetNode) el = cf_lv(f, ref, nt_str(nt, ref, "name"));
  else if (rk == NK_InstanceVariableTargetNode) { int els[64]; int n = cf_ivar_els(f, ref, nt_str(nt, ref, "name"), els, 64); for (int i = 0; i < n; i++) cf_all(f, els[i]); return; }
  else return;
  if (el < 0) return;
  int en = 0; const int *ex = nt_arr(nt, v, "exceptions", &en);
  if (en == 0) { cf_add_set(f, el, f->exc_set); return; }
  for (int i = 0; i < en; i++) {
    int x = cf_is_class_const(f, ex[i]);
    if (x >= 0) cf_add_set(f, el, f->desc[x]);
    else if (nt_kind(nt, ex[i]) == NK_ConstantReadNode || nt_kind(nt, ex[i]) == NK_ConstantPathNode) cf_add_set(f, el, f->exc_set);  /* a builtin class: its user subclasses too */
    else cf_all(f, el);
  }
}

static void cf_node(CF *f, int v) {
  Compiler *c = f->c;
  const NodeTable *nt = f->nt;
  NodeKind k = nt_kind(nt, v);
  switch (k) {
  case NK_NONE:
  case NK_NilNode: case NK_TrueNode: case NK_FalseNode: case NK_IntegerNode: case NK_FloatNode:
  case NK_RationalNode: case NK_ImaginaryNode: case NK_StringNode: case NK_SymbolNode:
  case NK_InterpolatedStringNode: case NK_InterpolatedSymbolNode: case NK_XStringNode:
  case NK_InterpolatedXStringNode: case NK_RegularExpressionNode: case NK_InterpolatedRegularExpressionNode:
  case NK_SourceFileNode: case NK_SourceLineNode: case NK_SourceEncodingNode: case NK_DefinedNode:
  case NK_DefNode: case NK_ClassNode: case NK_ModuleNode: case NK_SingletonClassNode: case NK_AliasMethodNode:
  case NK_AliasGlobalVariableNode: case NK_UndefNode: case NK_MatchPredicateNode: case NK_MatchRequiredNode:
  case NK_RedoNode: case NK_RetryNode: case NK_BackReferenceReadNode: case NK_NumberedReferenceReadNode:
  case NK_ParametersNode: case NK_BlockParametersNode: case NK_NumberedParametersNode:
  case NK_RequiredParameterNode: case NK_RestParameterNode: case NK_KeywordRestParameterNode:
  case NK_BlockParameterNode: case NK_InNode: case NK_EmbeddedStatementsNode:
  case NK_PreExecutionNode: case NK_PostExecutionNode: case NK_PinnedExpressionNode: case NK_PinnedVariableNode:
  case NK_ConstantPathTargetNode: case NK_CallTargetNode: case NK_IndexTargetNode:
    return;
  case NK_OptionalParameterNode: case NK_OptionalKeywordParameterNode: {
    /* a default: into the parameter it defaults */
    int owner = cf_owner_block(f, v, 0);
    int d = cf_owner_def(f, v, 1, NULL);
    const char *nm = nt_str(nt, v, "name");
    int el = owner >= 0 && nt_kind(nt, owner) == NK_BlockNode ? cf_lv(f, nt_ref(nt, owner, "body") >= 0 ? nt_ref(nt, owner, "body") : owner, nm)
           : d >= 0 ? cf_lv_in(f, d, nm) : cf_lv(f, v, nm);
    cf_flow(f, nt_ref(nt, v, "value"), el);
    return;
  }
  case NK_SelfNode: {
    if (cf_in_exec_block(f, v) || nt_int(nt, v, "ie_rself", 0)) { cf_all(f, v); return; }
    int si = cf_scope_of(f, v);
    /* a self a pass gave a call as its receiver after the scopes were
       walked (`r` -> `self.r`) has none recorded: the call's is its */
    if (si == 0 && f->par && v < f->nnodes && f->par[v] >= 0) si = cf_scope_of(f, f->par[v]);
    /* `def (self.class).m`: the receiver is the enclosing scope's self */
    for (int x = v, q = f->par ? f->par[v] : -1; q >= 0; x = q, q = f->par[q]) {
      if (nt_kind(nt, q) != NK_DefNode) continue;
      if (nt_ref(nt, q, "receiver") == x && f->par[q] >= 0) si = cf_scope_of(f, f->par[q]);
      break;
    }
    int ik = cf_inst_class(f, si);
    if (ik >= 0) { cf_flow(f, f->self_el[ik], v); return; }
    Scope *s = &c->scopes[si];
    /* the Class object: of the class a class method runs for, or one below
       it; the class whose body this is */
    if (s->def_node >= 0 && s->is_cmethod && s->class_id >= 0) {
      /* a module's own (a module_function's, an `extend self`'s) runs for
         the module too, which its subtree does not list; a reopened
         runtime class's for its classes the program does not list */
      if (cf_open_self(f, s->class_id)) { cf_all(f, v); return; }
      cf_add_set(f, v, cf_classvals_of(f, f->desc[s->class_id]));
      if (f->mod[s->class_id]) cf_add_set(f, v, cf_classval(f, s->class_id));
    }
    else if (v < f->nnodes && c->node_cbody && c->node_cbody[v] >= 0) cf_add_set(f, v, cf_classval(f, c->node_cbody[v]));
    else if (s->def_node < 0 && cf_owner_block(f, v, 0) >= 0) cf_all(f, v);
    /* a top-level def is Object's, and runs for any object (a Kernel
       reopening's function copy is one): its self is anything */
    else if (s->def_node >= 0 && s->class_id < 0 && !s->is_cmethod) cf_all(f, v);
    return;
  }
  case NK_ArrayNode: {
    cf_add_set(f, v, cf_bv_set(f));
    if (f->directed) cf_el_obj(f, v);
    int n = 0; const int *els = nt_arr(nt, v, "elements", &n);
    for (int i = 0; i < n; i++)
      if (nt_kind(nt, els[i]) == NK_SplatNode) cf_share(f, v, nt_ref(nt, els[i], "expression"));
      else cf_store(f, v, els[i]);
    return;
  }
  case NK_HashNode: case NK_KeywordHashNode: {
    cf_add_set(f, v, cf_bv_set(f));
    if (f->directed) cf_el_obj(f, v);
    int n = 0; const int *els = nt_arr(nt, v, "elements", &n);
    for (int i = 0; i < n; i++) {
      if (nt_kind(nt, els[i]) == NK_AssocNode) cf_store(f, v, nt_ref(nt, els[i], "key"));
      if (nt_kind(nt, els[i]) == NK_AssocSplatNode) cf_share(f, v, nt_ref(nt, els[i], "value"));
      else cf_store(f, v, nt_ref(nt, els[i], "value"));
    }
    return;
  }
  case NK_AssocNode: case NK_AssocSplatNode: return;
  case NK_SplatNode: cf_flow(f, nt_ref(nt, v, "expression"), v); return;
  case NK_BlockArgumentNode: return;
  case NK_RangeNode: cf_add_set(f, v, cf_bv_set(f)); if (f->directed) cf_el_obj(f, v); cf_store(f, v, nt_ref(nt, v, "left")); cf_store(f, v, nt_ref(nt, v, "right")); return;
  case NK_ParenthesesNode: cf_flow(f, cf_tail(f, nt_ref(nt, v, "body")), v); return;
  case NK_StatementsNode: cf_flow(f, cf_tail(f, v), v); return;
  case NK_ElseNode: cf_flow(f, cf_tail(f, nt_ref(nt, v, "statements")), v); return;
  case NK_BeginNode: {
    cf_flow(f, cf_tail(f, nt_ref(nt, v, "statements")), v);
    cf_flow(f, nt_ref(nt, v, "else_clause"), v);
    for (int rc = nt_ref(nt, v, "rescue_clause"), d = 0; rc >= 0 && d < 64; rc = nt_ref(nt, rc, "subsequent"), d++)
      cf_flow(f, cf_tail(f, nt_ref(nt, rc, "statements")), v);
    return;
  }
  case NK_RescueNode: cf_rescue(f, v); return;

  case NK_IfNode: case NK_UnlessNode: {
    cf_flow(f, cf_tail(f, nt_ref(nt, v, "statements")), v);
    cf_flow(f, nt_ref(nt, v, k == NK_IfNode ? "subsequent" : "else_clause"), v);
    return;
  }
  case NK_CaseNode: case NK_CaseMatchNode: {
    cf_flow(f, nt_ref(nt, v, "else_clause"), v);
    int wn = 0; const int *w = nt_arr(nt, v, "conditions", &wn);
    for (int i = 0; i < wn; i++) cf_flow(f, cf_tail(f, nt_ref(nt, w[i], "statements")), v);
    return;
  }
  case NK_AndNode: case NK_OrNode: cf_flow(f, nt_ref(nt, v, "left"), v); cf_flow(f, nt_ref(nt, v, "right"), v); return;
  case NK_RescueModifierNode: cf_flow(f, nt_ref(nt, v, "expression"), v); cf_flow(f, nt_ref(nt, v, "rescue_expression"), v); return;
  /* nil, or what a break hands it (NK_BreakNode) */
  case NK_WhileNode: case NK_UntilNode: return;
  case NK_ForNode: {
    /* the collection it walked, or what a break hands it */
    cf_flow(f, nt_ref(nt, v, "collection"), v);
    int idx = nt_ref(nt, v, "index");
    if (idx >= 0 && nt_kind(nt, idx) == NK_LocalVariableTargetNode) cf_load(f, nt_ref(nt, v, "collection"), cf_lv(f, idx, nt_str(nt, idx, "name")));
    return;
  }
  case NK_LocalVariableWriteNode: case NK_LocalVariableOrWriteNode: case NK_LocalVariableAndWriteNode: {
    int val = nt_ref(nt, v, "value");
    int el = cf_lv(f, v, nt_str(nt, v, "name"));
    cf_flow(f, val, v);
    if (el < 0) cf_all(f, v);
    else { cf_flow(f, val, el); if (k != NK_LocalVariableWriteNode) cf_flow(f, el, v); }
    return;
  }
  case NK_LocalVariableOperatorWriteNode: {
    /* `x op= y`: the operator's value, a builtin's or the class's own */
    int val = nt_ref(nt, v, "value");
    int el = cf_lv(f, v, nt_str(nt, v, "name"));
    const char *op = nt_str(nt, v, "binary_operator");
    if (el < 0 || !op) { cf_all(f, v); return; }
    int argv1[1] = { val };
    int pidx = cf_set_of(f, el);
    if (pidx == CF_ALL) cf_all(f, v);
    else cf_call_known(f, v, pidx, el, op, argv1, 1, -1);
    cf_flow(f, v, el);
    return;
  }
  case NK_LocalVariableTargetNode: {
    int p = f->par ? f->par[v] : -1;
    if (p >= 0 && (nt_kind(nt, p) == NK_RescueNode || nt_kind(nt, p) == NK_ForNode)) return;
    if (cf_destructured_block_param(f, v)) return;   /* bound with the block's parameters */
    if (cf_masgn_target(f, v)) return;               /* bound by its multiple assignment */
    cf_all(f, cf_lv(f, v, nt_str(nt, v, "name")));
    return;
  }
  case NK_LocalVariableReadNode: {
    int el = cf_lv(f, v, nt_str(nt, v, "name"));
    if (el < 0) cf_all(f, v); else cf_flow(f, el, v);
    return;
  }
  case NK_InstanceVariableWriteNode: case NK_InstanceVariableOrWriteNode: case NK_InstanceVariableAndWriteNode:
  case NK_InstanceVariableOperatorWriteNode: {
    int val = nt_ref(nt, v, "value");
    if (cf_in_exec_block(f, v)) {
      cf_unite(f, v, val);
      if (k != NK_InstanceVariableWriteNode) cf_all(f, v);
      cf_ivar_write_any(f, nt_str(nt, v, "name"), v);
      return;
    }
    int els[64]; int n = cf_ivar_els(f, v, nt_str(nt, v, "name"), els, 64);
    if (k == NK_InstanceVariableOperatorWriteNode) {
      const char *op = nt_str(nt, v, "binary_operator");
      int argv1[1] = { val };
      int pidx = n > 0 ? cf_set_of(f, els[0]) : CF_ALL;
      if (pidx == CF_ALL || !op) cf_all(f, v); else cf_call_known(f, v, pidx, els[0], op, argv1, 1, -1);
    }
    else cf_flow(f, val, v);
    for (int i = 0; i < n; i++) {
      cf_flow(f, v, els[i]);
      if (k == NK_InstanceVariableOrWriteNode || k == NK_InstanceVariableAndWriteNode) cf_flow(f, els[i], v);
    }
    if (f->all_ivars) cf_all(f, v);
    return;
  }
  case NK_InstanceVariableTargetNode: {
    int p = f->par ? f->par[v] : -1;
    if (p >= 0 && nt_kind(nt, p) == NK_RescueNode) return;
    int els[64]; int n = cf_ivar_els(f, v, nt_str(nt, v, "name"), els, 64);
    for (int i = 0; i < n; i++) cf_all(f, els[i]);
    return;
  }
  case NK_InstanceVariableReadNode: {
    if (cf_in_exec_block(f, v)) { cf_all(f, v); return; }
    int els[64]; int n = cf_ivar_els(f, v, nt_str(nt, v, "name"), els, 64);
    for (int i = 0; i < n; i++) cf_flow(f, els[i], v);
    if (f->all_ivars) cf_all(f, v);
    return;
  }
  case NK_ClassVariableWriteNode: case NK_ClassVariableOrWriteNode: case NK_ClassVariableAndWriteNode:
  case NK_ClassVariableOperatorWriteNode: case NK_GlobalVariableWriteNode: case NK_GlobalVariableOrWriteNode:
  case NK_GlobalVariableAndWriteNode: case NK_GlobalVariableOperatorWriteNode: case NK_ConstantWriteNode:
  case NK_ConstantOrWriteNode: case NK_ConstantAndWriteNode: case NK_ConstantOperatorWriteNode: {
    int key = (k == NK_ClassVariableWriteNode || k == NK_ClassVariableOrWriteNode || k == NK_ClassVariableAndWriteNode || k == NK_ClassVariableOperatorWriteNode) ? CF_K_CVAR
            : (k == NK_ConstantWriteNode || k == NK_ConstantOrWriteNode || k == NK_ConstantAndWriteNode || k == NK_ConstantOperatorWriteNode) ? CF_K_CONST : CF_K_GVAR;
    const char *nm = nt_str(nt, v, "name");
    if (key == CF_K_GVAR && nm && nm[0] == '$') nm = comp_resolve_gvar(c, nm + 1);
    int el = cf_entry(f, key, key == CF_K_CONST ? cf_const_key(nm) : nm);
    int val = nt_ref(nt, v, "value");
    int opw = k == NK_ClassVariableOperatorWriteNode || k == NK_GlobalVariableOperatorWriteNode || k == NK_ConstantOperatorWriteNode;
    if (opw) cf_all(f, v); else cf_flow(f, val, v);
    cf_flow(f, v, el);
    if (!opw && k != NK_ClassVariableWriteNode && k != NK_GlobalVariableWriteNode && k != NK_ConstantWriteNode) cf_flow(f, el, v);
    return;
  }
  case NK_ConstantPathWriteNode: case NK_ConstantPathOrWriteNode: case NK_ConstantPathAndWriteNode:
  case NK_ConstantPathOperatorWriteNode: {
    int t = nt_ref(nt, v, "target");
    const char *nm = t >= 0 ? nt_str(nt, t, "name") : nt_str(nt, v, "name");
    int val = nt_ref(nt, v, "value");
    if (k == NK_ConstantPathOperatorWriteNode) cf_all(f, v); else cf_flow(f, val, v);
    if (!nm) { cf_all(f, v); return; }
    cf_flow(f, v, cf_entry(f, CF_K_CONST, cf_const_key(nm)));
    if (k == NK_ConstantPathOrWriteNode || k == NK_ConstantPathAndWriteNode) cf_flow(f, cf_entry(f, CF_K_CONST, cf_const_key(nm)), v);
    return;
  }
  case NK_ClassVariableTargetNode: cf_all(f, cf_entry(f, CF_K_CVAR, nt_str(nt, v, "name"))); return;
  case NK_GlobalVariableTargetNode: { const char *nm = nt_str(nt, v, "name"); if (nm && nm[0] == '$') nm = comp_resolve_gvar(c, nm + 1); cf_all(f, cf_entry(f, CF_K_GVAR, nm)); return; }
  case NK_ConstantTargetNode: cf_all(f, cf_entry(f, CF_K_CONST, cf_const_key(nt_str(nt, v, "name")))); return;
  case NK_ClassVariableReadNode: cf_flow(f, cf_entry(f, CF_K_CVAR, nt_str(nt, v, "name")), v); return;
  case NK_GlobalVariableReadNode: {
    const char *nm = nt_str(nt, v, "name");
    if (!nm) { cf_all(f, v); return; }
    /* `$!`, `$~`, `$1`: the runtime's own */
    if (nm[0] == '$' && (nm[1] == '!' || nm[1] == '@')) { cf_all(f, v); return; }
    if (nm[0] == '$' && !((nm[1] >= 'a' && nm[1] <= 'z') || (nm[1] >= 'A' && nm[1] <= 'Z') || nm[1] == '_')) return;
    cf_flow(f, cf_entry(f, CF_K_GVAR, comp_resolve_gvar(c, nm + 1)), v);
    return;
  }
  case NK_ConstantReadNode: case NK_ConstantPathNode: {
    const char *nm = nt_str(nt, v, "name");
    if (!nm) { cf_all(f, v); return; }
    /* a class body's `m` / `self.m`, which the body desugar sends to the
       class: in a block run under another self it is that self
       (ie_rself_cmethod_call) */
    if (f->par && v < f->nnodes && f->par[v] >= 0 && nt_kind(nt, f->par[v]) == NK_CallNode &&
        nt_ref(nt, f->par[v], "receiver") == v && nt_int(nt, f->par[v], "self_call", 0) && cf_in_exec_block(f, v)) {
      cf_all(f, v);
      return;
    }
    int kc = comp_class_index(c, nm);
    if (kc >= 0) { cf_add_set(f, v, cf_classval(f, kc)); return; }   /* the Class object */
    if (!cf_entry_has(f, CF_K_CONSTW, cf_const_key(nm))) return;   /* a builtin's: ARGV, Float::INFINITY */
    cf_flow(f, cf_entry(f, CF_K_CONST, cf_const_key(nm)), v);
    return;
  }
  case NK_MultiWriteNode: {
    /* `a, (b, c), *d = value`: each name takes an element of the value, or
       the value itself when it is no Array (then the others take nil), or
       what a to_ary of the program's answers; the rest takes an Array */
    int val = nt_ref(nt, v, "value");
    cf_flow(f, val, v);
    cf_masgn_targets(f, v, val, 0);
    return;
  }
  case NK_MultiTargetNode: return;
  case NK_YieldNode: {
    int mi = cf_owner_def(f, v, 0, NULL);
    if (mi < 0) { cf_all(f, v); return; }
    cf_flow(f, f->yval_el[mi], v);
    int a = nt_ref(nt, v, "arguments"), an = 0;
    const int *av = a >= 0 ? nt_arr(nt, a, "arguments", &an) : NULL;
    int spread = 0;
    for (int i = 0; i < an; i++) if (nt_kind(nt, av[i]) == NK_SplatNode || nt_kind(nt, av[i]) == NK_KeywordHashNode) spread = 1;
    if (spread || an > CF_YARGS) {
      for (int i = 0; i < an; i++) for (int y = 0; y < CF_YARGS; y++)
        cf_flow(f, nt_kind(nt, av[i]) == NK_SplatNode ? nt_ref(nt, av[i], "expression") : av[i], f->yarg_el[mi][y]);
      return;
    }
    for (int i = 0; i < an; i++) cf_flow(f, av[i], f->yarg_el[mi][i]);
    return;
  }
  case NK_ReturnNode: {
    int a = nt_ref(nt, v, "arguments"), an = 0;
    const int *av = a >= 0 ? nt_arr(nt, a, "arguments", &an) : NULL;
    int lam = -1;
    int mi = cf_owner_def(f, v, 1, &lam);
    int to = lam >= 0 ? lam : mi >= 0 ? f->ret_el[mi] : -1;
    if (to < 0) return;
    for (int i = 0; i < an; i++) cf_flow(f, nt_kind(nt, av[i]) == NK_SplatNode ? nt_ref(nt, av[i], "expression") : av[i], to);
    return;
  }
  case NK_NextNode: case NK_BreakNode: {
    int a = nt_ref(nt, v, "arguments"), an = 0;
    const int *av = a >= 0 ? nt_arr(nt, a, "arguments", &an) : NULL;
    if (an == 0) return;
    int blk = cf_owner_block(f, v, 1);
    if (blk < 0) {
      /* a break is its loop's value; a next's argument in a loop goes nowhere */
      int loop = k == NK_BreakNode ? cf_owner_loop(f, v) : -1;
      for (int i = 0; loop >= 0 && i < an; i++) cf_flow(f, nt_kind(nt, av[i]) == NK_SplatNode ? nt_ref(nt, av[i], "expression") : av[i], loop);
      return;
    }
    /* a next is the block's value; a break is the call's */
    int to = blk;
    if (k == NK_BreakNode) {
      to = f->par ? f->par[blk] : -1;
      if (to < 0 || nt_kind(nt, to) != NK_CallNode) { if (nt_kind(nt, blk) == NK_LambdaNode) to = blk; else return; }
    }
    for (int i = 0; i < an; i++) cf_flow(f, nt_kind(nt, av[i]) == NK_SplatNode ? nt_ref(nt, av[i], "expression") : av[i], to);
    return;
  }
  case NK_BlockNode: {
    cf_flow(f, cf_tail(f, nt_ref(nt, v, "body")), v);
    int p = f->par ? f->par[v] : -1;
    /* a block whose call the walk does not bind (a super's) takes anything */
    if (p < 0 || (nt_kind(nt, p) != NK_CallNode && nt_kind(nt, p) != NK_LambdaNode)) cf_all_block_params(f, v);
    return;
  }
  case NK_LambdaNode: {
    cf_add_set(f, v, cf_bv_set(f));
    cf_unite(f, v, cf_tail(f, nt_ref(nt, v, "body")));
    cf_all_block_params(f, v);
    return;
  }
  case NK_CallNode: cf_call(f, v); return;
  case NK_CallOrWriteNode: case NK_CallAndWriteNode:
  case NK_IndexOrWriteNode: case NK_IndexAndWriteNode: case NK_IndexOperatorWriteNode:
    cf_call_write(f, v); return;
  case NK_SuperNode: case NK_ForwardingSuperNode: {
    int mi = cf_owner_def(f, v, 0, NULL);
    if (mi < 0) { cf_all(f, v); return; }
    Scope *s = &c->scopes[mi];
    if (!s->name) { cf_all(f, v); return; }
    int blk = nt_ref(nt, v, "block");
    if (s->is_cmethod && sp_streq(s->name, "new") && s->class_id >= 0) cf_add_set(f, v, f->desc[s->class_id]);
    /* the ancestors' methods of the name: by name, which is a superset */
    CFByName *b = cf_byname(f, s->name);
    int argv2[256], argc2 = 0;
    if (k == NK_SuperNode) {
      int a = nt_ref(nt, v, "arguments"), an = 0;
      const int *av = a >= 0 ? nt_arr(nt, a, "arguments", &an) : NULL;
      for (int i = 0; i < an && argc2 < 256; i++) argv2[argc2++] = av[i];
    }
    const int *mis = s->is_cmethod ? b->cmi : b->mi;
    int nmis = s->is_cmethod ? b->ncm : b->n;
    int others = 0;
    for (int i = 0; i < nmis; i++) {
      int t = mis[i];
      if (t == mi) continue;
      others++;
      cf_flow(f, f->ret_el[t], v);
      if (k == NK_SuperNode) cf_bind_args(f, t, argv2, argc2);
      else {
        /* the same parameters, by position */
        Scope *ts = &c->scopes[t];
        for (int p = 0; p < s->nparams && p < ts->nparams; p++) cf_flow(f, cf_param_el(f, mi, p), cf_param_el(f, t, p));
        if (ts->nparams != s->nparams) for (int p = 0; p < ts->nparams; p++) for (int q = 0; q < s->nparams; q++) cf_flow(f, cf_param_el(f, mi, q), cf_param_el(f, t, p));
      }
      if (blk >= 0) cf_bind_block(f, t, blk);
      else if (f->yval_el[mi] >= 0) {
        /* the block handed on: the parent's yields reach this method's block */
        for (int y = 0; y < CF_YARGS; y++) cf_flow(f, f->yarg_el[t][y], f->yarg_el[mi][y]);
        cf_flow(f, f->yval_el[mi], f->yval_el[t]);
      }
    }
    /* The methods above are every method of the name, a superset of the
       ancestors'. When no ancestor of the program's own (the superclass
       chain, the modules the class includes) has the name, the super runs
       a builtin ancestor's method (Exception#initialize, Array#push, a
       Struct's): its value is its own, built from the arguments, and self
       is its receiver, as for a bare builtin call (Object#freeze answers
       it). A native class's binding answers as its declaration says. */
    int anc_user = 0;
    if (s->class_id >= 0 && s->class_id < c->nclasses) {
      ClassInfo *ci = &c->classes[s->class_id];
      int par = ci->parent;
      if (par >= 0 && par < c->nclasses)
        anc_user = (s->is_cmethod ? comp_cmethod_in_chain(c, par, s->name, NULL) : comp_method_in_chain(c, par, s->name, NULL)) >= 0;
      for (int m = 0; m < ci->nincluded_mods && !anc_user && !s->is_cmethod; m++) {
        int md = ci->included_mods[m];
        if (md >= 0 && md < c->nclasses && comp_method_in_chain(c, md, s->name, NULL) >= 0) anc_user = 1;
      }
    }
    if (!anc_user && !(s->is_cmethod && sp_streq(s->name, "new"))) {
      int ik = s->is_cmethod ? -1 : cf_inst_class(f, mi);
      int recv_el = ik >= 0 && !cf_selfless_fn(s->name) ? f->self_el[ik] : -1;
      int nk = ik >= 0 ? comp_native_answer_class(c, ik, s->name) : -1;
      if (nk >= 0 && nk != ik) cf_native_answer(f, v, recv_el, nk, s->name, argc2);
      else cf_builtin_rule(f, v, recv_el, argv2, argc2, blk, s->name);
    }
    return;
  }
  default:
    cf_all(f, v);
    return;
  }
}

/* ---- the pass ---- */

static void cf_collect_dyn(CF *f) {
  const NodeTable *nt = f->nt;
  /* the constants the program writes: a read of any other names a builtin */
  static const NodeKind cw[] = { NK_ConstantWriteNode, NK_ConstantOrWriteNode, NK_ConstantAndWriteNode,
    NK_ConstantOperatorWriteNode, NK_ConstantTargetNode };
  for (int q = 0; q < 5; q++)
    NT_FOREACH_KIND(nt, cw[q], id) { (void)cf_entry(f, CF_K_CONSTW, cf_const_key(nt_str(nt, id, "name"))); }
  static const NodeKind cpw[] = { NK_ConstantPathWriteNode, NK_ConstantPathOrWriteNode, NK_ConstantPathAndWriteNode,
    NK_ConstantPathOperatorWriteNode, NK_ConstantPathTargetNode };
  for (int q = 0; q < 5; q++)
    NT_FOREACH_KIND(nt, cpw[q], id) {
      int t = nt_ref(nt, id, "target");
      const char *nm = t >= 0 ? nt_str(nt, t, "name") : nt_str(nt, id, "name");
      if (nm) (void)cf_entry(f, CF_K_CONSTW, cf_const_key(nm)); else f->dyn_all = 1;
    }
  NT_FOREACH_KIND(nt, NK_CallNode, id) {
    const char *cn = nt_str(nt, id, "name");
    if (!cn) continue;
    if (sp_streq(cn, "instance_variable_set") || sp_streq(cn, "instance_variable_get") || sp_streq(cn, "remove_instance_variable")) f->all_ivars = 1;
    /* `inject(:m)`, `inject(init, :m)` and `each_with_object(x, &:m)` call m
       with arguments the pass does not see: m takes any class */
    {
      int a0 = nt_ref(nt, id, "arguments"), n0 = 0;
      const int *v0 = a0 >= 0 ? nt_arr(nt, a0, "arguments", &n0) : NULL;
      int by_sym = sp_streq(cn, "inject") || sp_streq(cn, "reduce");
      for (int i = 0; by_sym && i < n0; i++)
        if (nt_kind(nt, v0[i]) == NK_SymbolNode) cf_dyn_add(f, nt_str(nt, v0[i], "value"));
      int blk0 = nt_ref(nt, id, "block");
      if ((by_sym || sp_streq(cn, "each_with_object")) && blk0 >= 0 &&
          nt_kind(nt, blk0) == NK_BlockNode && nt_int(nt, blk0, "sym_proc_block", 0))
        cf_dyn_add(f, nt_str(nt, blk0, "sym_proc"));
    }
    if (!sp_streq(cn, "send") && !sp_streq(cn, "__send__") && !sp_streq(cn, "public_send") &&
        !sp_streq(cn, "method") && !sp_streq(cn, "public_method") && !sp_streq(cn, "instance_method") &&
        !sp_streq(cn, "define_method") && !sp_streq(cn, "define_singleton_method") &&
        !sp_streq(cn, "alias_method") && !sp_streq(cn, "singleton_method") && !sp_streq(cn, "respond_to?") &&
        !sp_streq(cn, "method_defined?") && !sp_streq(cn, "instance_method"))
      continue;
    int a = nt_ref(nt, id, "arguments"), an = 0;
    const int *av = a >= 0 ? nt_arr(nt, a, "arguments", &an) : NULL;
    int any = 0;
    /* a send of a literal name is that call (cf_call), and an alias_method
       of two literal names an alias the class table has: neither leaves a
       method to be called with arguments the pass does not see */
    int is_send = sp_streq(cn, "send") || sp_streq(cn, "__send__") || sp_streq(cn, "public_send");
    if ((is_send || sp_streq(cn, "alias_method")) && an >= (is_send ? 1 : 2)) {
      int lits = 1;
      for (int i = 0; i < (is_send ? 1 : 2) && lits; i++) {
        NodeKind ak = nt_kind(nt, av[i]);
        lits = (ak == NK_SymbolNode && nt_str(nt, av[i], "value")) || (ak == NK_StringNode && nt_str(nt, av[i], "content"));
      }
      if (lits) continue;
    }
    for (int i = 0; i < an; i++) {
      NodeKind ak = nt_kind(nt, av[i]);
      const char *s = ak == NK_SymbolNode ? nt_str(nt, av[i], "value") : ak == NK_StringNode ? nt_str(nt, av[i], "content") : NULL;
      if (!s) continue;
      cf_dyn_add(f, s);
      any = 1;
    }
    if (!any && !sp_streq(cn, "respond_to?") && !sp_streq(cn, "method_defined?")) f->dyn_all = 1;
  }
}

/* ---- blocks run under another self ---- */

/* a call that runs its block with another self (or as a method body) */
static int cf_exec_name(const char *nm) {
  return nm && (sp_streq(nm, "instance_exec") || sp_streq(nm, "instance_eval") || sp_streq(nm, "class_exec") ||
                sp_streq(nm, "class_eval") || sp_streq(nm, "module_exec") || sp_streq(nm, "module_eval") ||
                sp_streq(nm, "define_method") || sp_streq(nm, "define_singleton_method"));
}
/* a call that may hand its block to such a call: by name, or a method of
   the name whose block parameter does */
static int cf_exec_call(CF *f, const char *nm) {
  if (cf_exec_name(nm)) return 1;
  if (!nm) return 0;
  CFByName *b = cf_byname(f, nm);
  for (int i = 0; i < b->n; i++) if (f->exec_esc[b->mi[i]]) return 1;
  for (int i = 0; i < b->ncm; i++) if (f->exec_esc[b->cmi[i]]) return 1;
  return 0;
}
/* Which blocks may run with a self that is not the scope's: one a call
   above hands to instance_exec and its kin, directly or through the
   block parameters of the program's methods (a fixpoint: `def check(&b) =
   new.instance_exec(&b)`), and every proc and lambda when one of those
   calls takes a block from elsewhere (`instance_exec(&pr)`). A method
   whose block parameter is stored or passed on as a value is taken as
   handing it on. */
static void cf_collect_exec(CF *f) {
  Compiler *c = f->c;
  const NodeTable *nt = f->nt;
  int procs = 0;
  for (int changed = 1; changed; ) {
    changed = 0;
    NT_FOREACH_KIND(nt, NK_BlockArgumentNode, id) {
      int e = nt_ref(nt, id, "expression");
      if (e >= 0 && nt_kind(nt, e) == NK_SymbolNode) continue;
      int p = f->par ? f->par[id] : -1;
      while (p >= 0 && nt_type(nt, p) && sp_streq(nt_type(nt, p), "ArgumentsNode")) p = f->par[p];
      if (p < 0 || nt_kind(nt, p) != NK_CallNode || !cf_exec_call(f, nt_str(nt, p, "name"))) continue;
      int mi = cf_owner_def(f, id, 1, NULL);
      Scope *m = mi >= 0 ? &c->scopes[mi] : NULL;
      int own = m && m->blk_param && (e < 0 ? m->blk_param[0] == 0 :
                nt_kind(nt, e) == NK_LocalVariableReadNode && nt_str(nt, e, "name") && sp_streq(nt_str(nt, e, "name"), m->blk_param));
      if (own) { if (!f->exec_esc[mi]) { f->exec_esc[mi] = 1; changed = 1; } }
      else procs = 1;
    }
    /* a block parameter read as a value: stored, passed, returned */
    NT_FOREACH_KIND(nt, NK_LocalVariableReadNode, id) {
      int mi = cf_owner_def(f, id, 1, NULL);
      if (mi < 0 || f->exec_esc[mi]) continue;
      Scope *m = &c->scopes[mi];
      const char *nm = nt_str(nt, id, "name");
      if (!m->blk_param || !m->blk_param[0] || !nm || !sp_streq(nm, m->blk_param)) continue;
      int p = f->par ? f->par[id] : -1;
      if (p >= 0 && nt_kind(nt, p) == NK_BlockArgumentNode) continue;
      if (p >= 0 && nt_kind(nt, p) == NK_CallNode && nt_ref(nt, p, "receiver") == id) {
        const char *cn = nt_str(nt, p, "name");
        if (cn && (sp_streq(cn, "call") || sp_streq(cn, "()") || sp_streq(cn, "yield") || sp_streq(cn, "===") ||
                   sp_streq(cn, "[]") || sp_streq(cn, "arity") || sp_streq(cn, "nil?") || sp_streq(cn, "lambda?") ||
                   sp_streq(cn, "parameters"))) continue;
      }
      f->exec_esc[mi] = 1; changed = 1;
    }
  }
  NT_FOREACH_KIND(nt, NK_CallNode, id) {
    int blk = nt_ref(nt, id, "block");
    if (blk < 0 || nt_kind(nt, blk) != NK_BlockNode) continue;
    const char *nm = nt_str(nt, id, "name");
    if (cf_exec_call(f, nm) ||
        (procs && nm && (sp_streq(nm, "proc") || sp_streq(nm, "lambda") || sp_streq(nm, "new"))))
      f->exec_blk[blk] = 1;
  }
  if (procs) NT_FOREACH_KIND(nt, NK_LambdaNode, id) f->exec_blk[id] = 1;
}
/* node v runs in a block that may have another self */
static int cf_in_exec_block(CF *f, int v) {
  for (int q = f->par ? f->par[v] : -1, d = 0; q >= 0 && d < 100000; q = f->par[q], d++) {
    NodeKind k = nt_kind(f->nt, q);
    if ((k == NK_BlockNode || k == NK_LambdaNode) && q < f->nnodes && f->exec_blk[q]) return 1;
    if (k == NK_DefNode || k == NK_ClassNode || k == NK_ModuleNode || k == NK_SingletonClassNode) return 0;
  }
  return 0;
}
/* an ivar written where self is unknown: into the ivar of the name of
   every class, the class-level ones and main's */
static void cf_ivar_write_any(CF *f, const char *name, int v) {
  if (!name) return;
  for (int k = 0; k < f->c->nclasses; k++) {
    if (!f->mod[k]) cf_flow(f, v, cf_entry(f, f->fam[k], name));
    cf_flow(f, v, cf_entry(f, -(k + 2), name));
  }
  cf_flow(f, v, cf_entry(f, CF_K_MAIN, name));
}

static int cf_scope_has_super(CF *f, int mi) {
  Scope *s = &f->c->scopes[mi];
  if (s->body < 0) return 0;
  int body = s->body;
  const NodeTable *nt = f->nt;
  int has = 0;
  NT_FOREACH_KIND(nt, NK_ForwardingSuperNode, id) {
    if (f->c->nscope[id] == mi) { has = 1; break; }
  }
  if (has) return 1;
  NT_FOREACH_KIND(nt, NK_SuperNode, id) {
    if (f->c->nscope[id] == mi && nt_ref(nt, id, "block") < 0) { has = 1; break; }
  }
  (void)body;
  return has;
}

/* SPINEL_CLS_FACTS=why: for the receivers with no fact, what made their
   element every class (the source line of the rule here, or the cap),
   and the largest elements by node count with their reason */
static int cf_why_cmp(const void *a, const void *b) { return ((const int *)b)[1] - ((const int *)a)[1]; }
static int cf_seed_key_cmp(const void *a, const void *b) {
  const int *x = a, *y = b;
  return x[0] != y[0] ? (x[0] < y[0] ? -1 : 1) : x[1] != y[1] ? (x[1] < y[1] ? -1 : 1) : 0;
}
static int cf_seed_count_cmp(const void *a, const void *b) { return ((const int *)b)[2] - ((const int *)a)[2]; }
static void cf_why_report(CF *f) {
  const NodeTable *nt = f->nt;
  int maxl = 4096, *byline = calloc((size_t)maxl + 2, sizeof *byline);
  int *size = calloc((size_t)f->nel, sizeof *size), *recv_any = calloc((size_t)f->nel, sizeof *recv_any);
  if (!byline || !size || !recv_any) cf_oom();
  int total = 0;
  for (int v = 0; v < f->nnodes; v++) size[cf_find(f, v)]++;
  NT_FOREACH_KIND(nt, NK_CallNode, id) {
    int r = nt_ref(nt, id, "receiver");
    if (r < 0 || cf_set_of(f, r) != CF_ALL) continue;
    int root = cf_find(f, r), w = f->why[root];
    byline[w == CF_WHY_CAP ? maxl + 1 : w > 0 && w <= maxl ? w : 0]++;
    recv_any[root]++;
    total++;
  }
  fprintf(stderr, "cls-fact-why: %d receivers with no fact\n", total);
  for (int l = 0; l <= maxl + 1; l++)
    if (byline[l]) fprintf(stderr, "cls-fact-why: %6d %s%d\n", byline[l], l == maxl + 1 ? "cap " : l ? "analyze_cls.c:" : "unknown ", l == maxl + 1 ? CLS_SET_MAX : l);
  int nr = 0, (*roots)[2] = malloc(sizeof *roots * (size_t)f->nel);
  if (!roots) cf_oom();
  for (int x = 0; x < f->nel; x++) if (recv_any[x]) { roots[nr][0] = x; roots[nr][1] = recv_any[x]; nr++; }
  qsort(roots, (size_t)nr, sizeof *roots, cf_why_cmp);
  for (int i = 0; i < nr && i < 10; i++) {
    int x = roots[i][0];
    fprintf(stderr, "cls-fact-why: element %d: %d receivers, %d nodes, %s%d\n", x, roots[i][1], size[x],
            f->why[x] == CF_WHY_CAP ? "cap " : "analyze_cls.c:", f->why[x] == CF_WHY_CAP ? CLS_SET_MAX : f->why[x]);
    /* back through the calls on a receiver with no fact, to where it began */
    for (int step = 0, root = x; step < 12; step++) {
      int e = f->why_el[root];
      if (e < 0 || e >= f->nnodes) { fprintf(stderr, "cls-fact-why:     <- element %d (not a node)\n", e); break; }
      int fid = (int)nt_int(nt, e, "node_file", 0);
      const char *fp = nt_file_path(nt, fid), *nm = nt_str(nt, e, "name");
      fprintf(stderr, "cls-fact-why:     <- %s:%d %s %s (rule %d)\n", fp ? fp : "?", (int)nt_int(nt, e, "node_line", 0),
              nt_type(nt, e), nm ? nm : "", f->why[root]);
      int r = nt_kind(nt, e) == NK_CallNode ? nt_ref(nt, e, "receiver") : -1;
      if (r < 0 || cf_set_of(f, r) != CF_ALL) break;
      int nroot = cf_find(f, r);
      if (nroot == root) { fprintf(stderr, "cls-fact-why:     (its receiver is in the same element)\n"); break; }
      root = nroot;
    }
  }
  /* each receiver with no fact, back to where its every-class began: the
     rule and the node (or element) it named */
  {
    int cap = f->nnodes + 1, nall = 0, ns = 0;
    int (*seed)[3] = calloc((size_t)cap, sizeof *seed);   /* line, element, count */
    if (!seed) cf_oom();
    NT_FOREACH_KIND(nt, NK_CallNode, id) {
      int r = nt_ref(nt, id, "receiver");
      if (r < 0 || cf_set_of(f, r) != CF_ALL) continue;
      int root = cf_find(f, r), line = f->why[root], el = f->why_el[root];
      for (int step = 0; step < 200; step++) {
        int nxt = -1;
        if (el >= 0 && el < f->nnodes && nt_kind(nt, el) == NK_CallNode) {
          int rr = nt_ref(nt, el, "receiver");
          if (rr >= 0 && cf_set_of(f, rr) == CF_ALL) nxt = cf_find(f, rr);
        }
        if (nxt < 0 || nxt == root) break;
        root = nxt; line = f->why[root]; el = f->why_el[root];
      }
      if (nall < cap) { seed[nall][0] = line; seed[nall][1] = el; seed[nall][2] = 1; nall++; }
    }
    /* group equal seeds, then the largest groups first */
    qsort(seed, (size_t)nall, sizeof *seed, cf_seed_key_cmp);
    for (int i = 0; i < nall; i++) {
      if (ns > 0 && seed[ns - 1][0] == seed[i][0] && seed[ns - 1][1] == seed[i][1]) { seed[ns - 1][2]++; continue; }
      memcpy(seed[ns++], seed[i], sizeof seed[0]);
    }
    qsort(seed, (size_t)ns, sizeof *seed, cf_seed_count_cmp);
    for (int i = 0; i < ns && i < 25; i++) {
      int e = seed[i][1];
      if (e >= f->nnodes) {
        /* a slot: name the local or parameter */
        for (int mi = 0; mi < f->c->nscopes; mi++)
          for (int q = 0; q < f->nlv[mi]; q++)
            if (f->lv_el[mi] && f->lv_el[mi][q] == e) {
              Scope *sc = &f->c->scopes[mi];
              const char *ln = q < sc->nlocals ? sc->locals[q].name : "?";
              fprintf(stderr, "cls-fact-why: seed %5d receivers: rule %d at local %s of %s%s%s\n", seed[i][2], seed[i][0], ln ? ln : "?",
                      sc->class_id >= 0 ? f->c->classes[sc->class_id].name : "", sc->is_cmethod ? "." : "#", sc->name ? sc->name : "?");
              goto named;
            }
      }
      const char *fp = e >= 0 && e < f->nnodes ? nt_file_path(nt, (int)nt_int(nt, e, "node_file", 0)) : NULL;
      const char *nm = e >= 0 && e < f->nnodes ? nt_str(nt, e, "name") : NULL;
      fprintf(stderr, "cls-fact-why: seed %5d receivers: rule %d at %s:%d %s %s\n", seed[i][2], seed[i][0],
              fp ? fp : "(element)", e >= 0 && e < f->nnodes ? (int)nt_int(nt, e, "node_line", 0) : e,
              e >= 0 && e < f->nnodes ? nt_type(nt, e) : "", nm ? nm : "");
      named:;
    }
    free(seed);
  }
  /* the unions that built the largest element, by rule, weighted by the
     smaller side (what each union brought in) */
  if (nr > 0) {
    int big = roots[0][0];
    long *w = calloc((size_t)maxl + 1, sizeof *w);
    int *cnt = calloc((size_t)maxl + 1, sizeof *cnt);
    if (!w || !cnt) cf_oom();
    for (int i = 0; i < f->nuev; i++) {
      if (cf_find(f, f->uev[i][1]) != big) continue;
      int l = f->uev[i][0] > 0 && f->uev[i][0] <= maxl ? f->uev[i][0] : 0;
      w[l] += f->uev[i][2]; cnt[l]++;
    }
    for (int l = 0; l <= maxl; l++)
      if (w[l] >= 200) fprintf(stderr, "cls-fact-why: unions into element %d: analyze_cls.c:%d brought %ld (%d unions)\n", big, l, w[l], cnt[l]);
    free(w); free(cnt);
  }
  free(roots); free(byline); free(size); free(recv_any);
}

/* SPINEL_CLS_FACTS: each call's receiver fact, as the oracle reads it */
static void cf_dump_facts(Compiler *c) {
  const NodeTable *nt = c->nt;
  NT_FOREACH_KIND(nt, NK_CallNode, id) {
    /* a call on self has no fact of its own: a consumer holds every
       class there, and so does the dump */
    int r = nt_ref(nt, id, "receiver");
    const ClsSet *s = r >= 0 ? cls_fact_node(c, r) : NULL;
    const char *fp = nt_file_path(nt, (int)nt_int(nt, id, "node_file", 0));
    fprintf(stderr, "cls-fact: %s:%d %s receiver:", fp && *fp ? fp : "?", (int)nt_int(nt, id, "node_line", 0), nt_str(nt, id, "name") ? nt_str(nt, id, "name") : "?");
    if (!s) fprintf(stderr, r < 0 ? " ANY self" : " ANY");
    else if (s->n == 0) fprintf(stderr, " none");
    else for (int i = 0; i < s->n; i++) {
      int k = s->cls[i] >= c->nclasses ? s->cls[i] - c->nclasses : s->cls[i];
      /* the Ruby name, as class_ruby_name builds it (a singleton
         subclass is its parent; a segment qualify_colliding_classes
         rewrote is its leaf), without its cache: the name is not
         settled this early */
      char cn[512] = ""; int chain[16], d = 0;
      for (int e = singleton_visible_ci(c, k); e >= 0 && d < 16; e = c->classes[e].enclosing_class) chain[d++] = e;
      for (int q = d - 1; q >= 0; q--) {
        const char *seg = c->classes[chain[q]].name ? c->classes[chain[q]].name : "?";
        const char *t = q < d - 1 ? strstr(seg, "__") : NULL;
        while (t) { seg = t + 2; t = strstr(seg, "__"); }
        size_t l = strlen(cn);
        snprintf(cn + l, sizeof cn - l, "%s%s", q < d - 1 ? "::" : "", seg);
      }
      fprintf(stderr, s->cls[i] >= c->nclasses ? " Class(%s)" : " %s", cn);
    }
    if (s && s->bv) fprintf(stderr, " +builtin");
    fprintf(stderr, "\n");
  }
}

static void cf_solve(Compiler *c, int directed, int dump_facts) {
  const NodeTable *nt = c->nt;
  CF f;
  memset(&f, 0, sizeof f);
  f.directed = directed;
  f.c = c; f.nt = nt; f.nnodes = nt->count;
  f.par = du_parent_map(nt);
  /* a receiver a pass gave a call after the map was made (`r` ->
     `self.r`) has the call as its parent, so the blocks around it are
     seen */
  if (f.par)
    NT_FOREACH_KIND(nt, NK_CallNode, id) {
      int r = nt_ref(nt, id, "receiver");
      if (r >= 0 && r < nt->count && f.par[r] < 0) f.par[r] = id;
    }
  /* The pool: CF_ALL and CF_EMPTY are sentinel indices that cf_pool answers
     without a lookup, so their entries are written here, as the sets they
     stand for. The hash table's rebuild hashes every entry below npool;
     left unwritten, CF_ALL's entry was heap garbage, with a member count
     that read past the struct and a hash that could alias a real set. */
  f.cpool = 256;
  f.pool = malloc(sizeof *f.pool * (size_t)f.cpool);
  if (!f.pool) cf_oom();
  memset(&f.pool[0], 0, sizeof f.pool[0] * 2);
  f.pool[CF_ALL].all = 1;
  f.npool = 2;
  /* the elements: the nodes first */
  f.cel = nt->count + 1024;
  f.uf = malloc(sizeof *f.uf * (size_t)f.cel);
  f.set = malloc(sizeof *f.set * (size_t)f.cel);
  if (!f.uf || !f.set) cf_oom();
  for (int i = 0; i < nt->count; i++) { f.uf[i] = i; f.set[i] = CF_EMPTY; }
  f.nel = nt->count;
  if (directed) {
    cf_grow_directed(&f); f.gsum = -1;
    f.dbg_seed = getenv("SPINEL_CLS_FLOW_SEED") != NULL; f.dbg_ptop = getenv("SPINEL_CLS_FLOW_PTOP") != NULL;
    f.pts_max = getenv("SPINEL_CLS_FLOW_PTSMAX") ? atoi(getenv("SPINEL_CLS_FLOW_PTSMAX")) : CF_PTS_MAX;
    if (f.pts_max < 1) f.pts_max = CF_PTS_MAX;
  }
  const char *dump = getenv("SPINEL_CLS_FACTS");
  if (dump && sp_streq(dump, "why") && !directed) {
    f.why = calloc((size_t)f.cel, sizeof *f.why);
    f.why_el = malloc(sizeof *f.why_el * (size_t)f.cel);
    f.usz = malloc(sizeof *f.usz * (size_t)f.cel);
    if (!f.why || !f.why_el || !f.usz) cf_oom();
    for (int i = 0; i < f.cel; i++) { f.why_el[i] = -1; f.usz[i] = 1; }
  }
  f.lv_el = calloc((size_t)c->nscopes + 1, sizeof *f.lv_el);
  f.nlv = malloc(sizeof(int) * ((size_t)c->nscopes + 1));
  f.ret_el = malloc(sizeof(int) * ((size_t)c->nscopes + 1));
  f.yval_el = malloc(sizeof(int) * ((size_t)c->nscopes + 1));
  f.yarg_el = malloc(sizeof *f.yarg_el * ((size_t)c->nscopes + 1));
  f.has_super = calloc((size_t)c->nscopes + 1, 1);
  f.protocol = calloc((size_t)c->nscopes + 1, 1);
  f.def_mi = malloc(sizeof(int) * ((size_t)nt->count + 1));
  f.self_el = malloc(sizeof(int) * ((size_t)c->nclasses + 1));
  f.own = malloc(sizeof(int) * ((size_t)c->nclasses + 1));
  f.desc = malloc(sizeof(int) * ((size_t)c->nclasses + 1));
  f.fam = malloc(sizeof(int) * ((size_t)c->nclasses + 1));
  f.mod = calloc((size_t)c->nclasses + 1, 1);
  f.open = malloc(sizeof(int) * ((size_t)c->nclasses + 1));
  f.exec_esc = calloc((size_t)c->nscopes + 1, 1);
  f.exec_blk = calloc((size_t)nt->count + 1, 1);
  if (!f.lv_el || !f.nlv || !f.ret_el || !f.yval_el || !f.yarg_el || !f.has_super || !f.protocol || !f.def_mi ||
      !f.self_el || !f.own || !f.desc || !f.fam || !f.mod || !f.open || !f.exec_esc || !f.exec_blk || !f.par) cf_oom();
  for (int k = 0; k < nt->count; k++) f.def_mi[k] = -1;
  for (int mi = 0; mi < c->nscopes; mi++) {
    Scope *s = &c->scopes[mi];
    f.nlv[mi] = s->nlocals;
    f.ret_el[mi] = cf_new_el(&f);
    f.yval_el[mi] = cf_new_el(&f);
    f.yarg_el[mi] = malloc(sizeof(int) * CF_YARGS);
    if (!f.yarg_el[mi]) cf_oom();
    for (int y = 0; y < CF_YARGS; y++) f.yarg_el[mi][y] = cf_new_el(&f);
    if (s->def_node >= 0 && s->def_node < nt->count && f.def_mi[s->def_node] < 0) f.def_mi[s->def_node] = mi;
  }
  /* the classes: modules, families, each class with the singleton classes
     made of it, each class's subtree (a module's: its includers') */
  for (int k = 0; k < c->nclasses; k++) {
    f.mod[k] = (unsigned char)(comp_class_is_module(c, &c->classes[k]) != 0);
    int r = k, d = 0;
    while (c->classes[r].parent >= 0 && c->classes[r].parent < c->nclasses && d++ < 1000) r = c->classes[r].parent;
    f.fam[k] = r;
  }
  for (int k = 0; k < c->nclasses; k++) {
    ClsSet s; memset(&s, 0, sizeof s);
    s.cls[s.n++] = k;
    for (int j = 0; j < c->nclasses && !s.all; j++)
      if (c->classes[j].is_singleton_of - 1 == k) { if (s.n < CLS_SET_MAX) s.cls[s.n++] = j; else s.all = 1; }
    f.own[k] = cf_pool(&f, &s);
  }
  for (int k = 0; k < c->nclasses; k++) {
    ClsSet s; memset(&s, 0, sizeof s);
    if (!f.mod[k]) s.cls[s.n++] = k;
    for (int j = 0; j < c->nclasses && !s.all; j++) {
      if (j == k || f.mod[j]) continue;
      int in = is_descendant(c, j, k);
      for (int x = j; x >= 0 && !in; x = c->classes[x].parent)
        for (int m = 0; m < c->classes[x].nincluded_mods && !in; m++)
          if (c->classes[x].included_mods[m] == k) in = 1;
      if (!in) continue;
      if (s.n < CLS_SET_MAX) s.cls[s.n++] = j; else s.all = 1;
    }
    f.desc[k] = cf_pool(&f, &s);
    f.self_el[k] = cf_new_el(&f);
    f.set[f.self_el[k]] = f.desc[k];
    /* (directed) self in a method an Array, Hash or String subclass runs
       is such a container (cf_construct) */
    if (directed) {
      const ClsSet *ds = &f.pool[f.desc[k]];
      int box = ds->all;
      for (int i = 0; i < ds->n && !box; i++) box = cf_container_class(c, ds->cls[i]);
      if (box) cf_ptop_set(&f, f.self_el[k]);
    }
    /* a class or module the compiler supplies, or one of the runtime's the
       program reopens, runs for any object */
    if (c->classes[k].def_node >= 0 && nt_int(nt, c->classes[k].def_node, "node_bi", 0) != 0) cf_all(&f, f.self_el[k]);
    if (cf_open_self(&f, k)) {
      cf_all(&f, f.self_el[k]);
      f.open[f.nopen++] = k;
    }
  }
  {
    ClsSet s; memset(&s, 0, sizeof s);
    for (int k = 0; k < c->nclasses && !s.all; k++)
      if (!f.mod[k] && class_is_exc_subclass(c, k)) { if (s.n < CLS_SET_MAX) s.cls[s.n++] = k; else s.all = 1; }
    f.exc_set = cf_pool(&f, &s);
  }
  f.fiber_ch = cf_new_el(&f);
  /* a yield whose value is read: not one in statement position ahead of
     another statement */
  f.yval_used = calloc((size_t)c->nscopes + 1, 1);
  if (!f.yval_used) cf_oom();
  NT_FOREACH_KIND(nt, NK_YieldNode, id) {
    int mi = cf_owner_def(&f, id, 0, NULL);
    if (mi < 0) continue;
    int p = f.par ? f.par[id] : -1;
    int used = 1;
    if (p >= 0 && nt_kind(nt, p) == NK_StatementsNode) {
      int n = 0; const int *b = nt_arr(nt, p, "body", &n);
      used = n > 0 && b[n - 1] == id;
    }
    if (used) f.yval_used[mi] = 1;
  }
  cf_collect_dyn(&f);
  cf_collect_exec(&f);
  for (int k = 0; k < c->nclasses && !f.has_mm; k++)
    if (comp_method_in_chain(c, k, "method_missing", NULL) >= 0) f.has_mm = 1;
  /* the parameters a call the analysis cannot see binds: anything */
  for (int mi = 1; mi < c->nscopes; mi++) {
    Scope *s = &c->scopes[mi];
    f.has_super[mi] = (unsigned char)cf_scope_has_super(&f, mi);
    if (!s->name) continue;
    /* a method named like a call the analysis does not follow (`bind`,
       `send`, ...): such a call binds nothing, so its parameters are left
       to hold anything rather than nothing (#8720) */
    if (cf_protocol_name(s->name) || cf_opaque_name(s->name) || cf_is_dyn(&f, s->name) ||
        s->is_proc_form || s->is_lowered_yield ||
        s->cs_synth || s->is_module_function || cf_prelude_scope(&f, mi) ||
        (c->n_cext_extensions && s->def_node >= 0 && nt_int(c->nt, s->def_node, "cext_stub", 0))) {
      f.protocol[mi] = 1;
      /* a copy's initialize_copy / initialize_dup / initialize_clone takes
         the original: an instance of the class, or of a subclass */
      if (s->def_node >= 0 && s->class_id >= 0 && !s->is_cmethod && s->nparams >= 1 &&
          (sp_streq(s->name, "initialize_copy") || sp_streq(s->name, "initialize_dup") || sp_streq(s->name, "initialize_clone")) &&
          !cf_opaque_name(s->name) && !cf_is_dyn(&f, s->name)) {
        int pe = cf_param_el(&f, mi, 0);
        if (pe >= 0) cf_add_set(&f, pe, f.desc[s->class_id]);
        for (int i = 1; i < s->nparams; i++) cf_all(&f, cf_param_el(&f, mi, i));
        if (s->blk_param && s->blk_param[0]) cf_all(&f, cf_lv_in(&f, mi, s->blk_param));
        continue;
      }
      /* a protocol a runtime module calls (Marshal's marshal_load, Psych's
         init_with, PP's pretty_print, JSON's to_json) runs only when the
         program names the module somewhere: else no call binds it */
      if (cf_protocol_name(s->name) && !cf_opaque_name(s->name) && !cf_is_dyn(&f, s->name) &&
          !s->is_proc_form && !s->is_lowered_yield && !s->cs_synth && !s->is_module_function && !cf_prelude_scope(&f, mi)) {
        const char *gate = cf_protocol_gate(s->name);
        if (gate && !cf_const_named(&f, gate)) continue;
      }
      if (f.dbg_seed && s->nparams > 0) fprintf(stderr, "cls-flow-proto: %s params %d%s%s%s%s%s%s%s%s file %s\n", s->name, s->nparams,
        cf_protocol_name(s->name) ? " proto" : "", cf_opaque_name(s->name) ? " opaque" : "", cf_is_dyn(&f, s->name) ? " dyn" : "",
        s->is_proc_form ? " procform" : "", s->is_lowered_yield ? " lyield" : "", s->cs_synth ? " cssynth" : "", s->is_module_function ? " modfn" : "",
        cf_prelude_scope(&f, mi) ? " prelude" : "", s->def_node >= 0 && nt_file_path(nt, (int)nt_int(nt, s->def_node, "node_file", 0)) ? nt_file_path(nt, (int)nt_int(nt, s->def_node, "node_file", 0)) : "-");
      cf_all_params(&f, mi);
    }
    if (s->blk_param && s->blk_param[0]) {
      int be = cf_lv_in(&f, mi, s->blk_param);
      cf_unite(&f, be, f.yval_el[mi]);
      cf_add_set(&f, be, cf_bv_set(&f));   /* a Proc: its own methods answer */
    }
  }
  /* Children first (a node's id is below its children's), so a receiver's
     read has met its slot when its call asks for the classes. The rounds
     with the builtin answers held back run to a fixpoint first; a round
     that lets them in follows, and the two alternate until a round of each
     changes nothing. */
  f.phase = 0;
  for (int round = 0; round < CF_ROUNDS; round++) {
    f.changed = 0; f.pending = 0;
    f.round = round;
    for (int v = nt->count - 1; v >= 0; v--) cf_node(&f, v);
    /* a method's value: its body's tail */
    for (int mi = 1; mi < c->nscopes; mi++) {
      Scope *s = &c->scopes[mi];
      if (s->body >= 0) cf_flow(&f, cf_tail(&f, s->body), f.ret_el[mi]);
    }
    if (f.changed) { f.phase = 0; continue; }
    if (f.phase == 1 || f.pending == 0) break;
    f.phase = 1;
  }
  /* the node facts */
  free(c->cls_fact); free(c->cls_pool);
  c->cls_fact = malloc(sizeof(int) * ((size_t)nt->count + 1));
  if (!c->cls_fact) cf_oom();
  for (int v = 0; v < nt->count; v++) c->cls_fact[v] = cf_set_of(&f, v);
  c->cls_fact_n = nt->count;
  c->cls_pool = f.pool; c->ncls_pool = f.npool;
  if (dump_facts) cf_dump_facts(c);
  if (f.why) cf_why_report(&f);
  /* the pass's own */
  free(f.par); free(f.uf); free(f.set); free(f.ph);
  for (int mi = 0; mi < c->nscopes; mi++) { free(f.lv_el[mi]); free(f.yarg_el[mi]); }
  free(f.lv_el); free(f.nlv); free(f.ret_el); free(f.yval_el); free(f.yarg_el); free(f.has_super); free(f.protocol);
  free(f.def_mi); free(f.why); free(f.why_el); free(f.usz); free(f.uev); free(f.open); free(f.exec_esc); free(f.exec_blk); free(f.self_el); free(f.own); free(f.desc); free(f.fam); free(f.mod); free(f.dyn); free(f.yval_used); free(f.has_native);
  for (int k = 0; k < f.ent_cap; k++) free((char *)f.ent[k].name);
  free(f.ent);
  for (int k = 0; k < f.bn_cap; k++) if (f.bn[k].name) { free((char *)f.bn[k].name); free(f.bn[k].mi); free(f.bn[k].cmi); free(f.bn[k].rd); free(f.bn[k].wr); }
  free(f.bn);
  if (directed && getenv("SPINEL_CLS_FLOW")) fprintf(stderr, "cls-flow-stats: elements %d objects %d edges %ld pts-adds %ld drain-visits %ld rounds %d\n", f.nel, f.nobj, f.st_edges, f.st_pts, f.st_drain, f.round + 1);
  if (directed && getenv("SPINEL_CLS_FLOW") && sp_streq(getenv("SPINEL_CLS_FLOW"), "why")) {
    int cap = 8192; int *cnt = calloc((size_t)cap * 2, sizeof(int));
    NT_FOREACH_KIND(nt, NK_CallNode, id) {
      int r = nt_ref(nt, id, "receiver");
      if (r < 0 || f.set[r] != CF_ALL) continue;
      int o = f.orig[r]; if (o < -cap || o > cap) o = 0;
      cnt[o + cap]++;
      if (getenv("SPINEL_CLS_FLOW_EACH")) fprintf(stderr, "cls-flow-any: line %d %s orig %d\n", (int)nt_int(nt, id, "node_line", 0), nt_str(nt, id, "name") ? nt_str(nt, id, "name") : "?", o);
    }
    for (int o = 0; o < cap * 2; o++)
      if (cnt[o]) fprintf(stderr, "cls-flow-why: %s line %d: %d receivers\n", o - cap > 0 ? "every-class rule at" : o - cap < 0 ? "a set past the cap at" : "unknown", o - cap < 0 ? cap - o : o - cap, cnt[o]);
    free(cnt);
  }
  if (directed) {
    free(f.orig);
    for (int i = 0; i < f.dcap; i++) free(f.succ[i]);
    free(f.succ); free(f.nsucc); free(f.csucc); free(f.inwl); free(f.wl); free(f.eh);
    for (int i = 0; i < f.dcap; i++) { free(f.psucc[i]); free(f.pts[i]); free(f.pdel[i]); free(f.ld[i]); free(f.st[i]); }
    free(f.pdel); free(f.npdel); free(f.cpdel);
    free(f.psucc); free(f.npsucc); free(f.cpsucc); free(f.pts); free(f.npts); free(f.cpts);
    free(f.ld); free(f.nld); free(f.cld); free(f.st); free(f.nst); free(f.cst);
    free(f.ptop); free(f.esc); free(f.elobj); free(f.summ); free(f.smc); free(f.obj_cont); free(f.fs);
  }
}

/* SPINEL_CLS_FLOW: the directed sets beside the unified ones, per call
   receiver: how many are every class in each, and where they differ (the
   directed set must lie inside the unified one wherever that one is
   bounded). The unified facts are the ones kept. */
/* the program's methods a call of the name on a value of set s may run: one
   arm each (an instance method, or a class method for a Class object);
   every class's for ANY */
static int cf_arms(Compiler *c, const ClsSet *s, int any, const char *nm) {
  int ms[64], n = 0;
  int lim = any ? 2 * c->nclasses : s->n;
  for (int i = 0; i < lim && n < 64; i++) {
    int k = any ? i : s->cls[i];
    int mi = k < c->nclasses ? comp_method_in_chain(c, k, nm, NULL) : comp_cmethod_in_chain(c, k - c->nclasses, nm, NULL);
    if (mi < 0) continue;
    int dup = 0;
    for (int j = 0; j < n && !dup; j++) dup = ms[j] == mi;
    if (!dup) ms[n++] = mi;
  }
  return n;
}
static void cf_flow_compare(Compiler *c, const int *df, const ClsSet *dp, int dn) {
  const NodeTable *nt = c->nt;
  long calls = 0, any_u = 0, any_d = 0, same = 0, narrower = 0, wider = 0;
  /* the arms (cf_arms) of the calls a program's method may answer */
  long ucalls = 0, arms_u = 0, arms_d = 0, mono_u = 0, mono_d = 0;
  struct { const char *nm; int n; } *amemo = calloc(8192, sizeof *amemo);
  NT_FOREACH_KIND(nt, NK_CallNode, id) {
    int r = nt_ref(nt, id, "receiver");
    if (r < 0 || r >= dn || r >= c->cls_fact_n) continue;
    calls++;
    int u = c->cls_fact[r], d = df[r];
    const ClsSet *us = &c->cls_pool[u], *ds = &dp[d];
    const char *anm = nt_str(nt, id, "name");
    if (anm && amemo) {
      unsigned h = sp_strhash(anm) & 8191u;
      while (amemo[h].nm && !sp_streq(amemo[h].nm, anm)) h = (h + 1) & 8191u;
      if (!amemo[h].nm) { amemo[h].nm = anm; amemo[h].n = cf_arms(c, NULL, 1, anm); }
      int all = amemo[h].n;
      if (all > 0) {
        int au = u == 0 ? all : cf_arms(c, us, 0, anm), ad = d == 0 ? all : cf_arms(c, ds, 0, anm);
        ucalls++; arms_u += au; arms_d += ad; mono_u += au <= 1; mono_d += ad <= 1;
      }
    }
    if (u == 0) any_u++;
    if (d == 0) any_d++;
    if (u == 0 && d == 0) { same++; continue; }
    if (u == 0) { narrower++; continue; }
    if (d == 0) { wider++; goto report; }
    {
      int sub = 1;
      for (int i = 0; i < ds->n && sub; i++) {
        int in = 0;
        for (int j = 0; j < us->n && !in; j++) in = us->cls[j] == ds->cls[i];
        sub = in;
      }
      NodeKind rk = nt_kind(nt, r);
      int lit = rk == NK_IntegerNode || rk == NK_FloatNode || rk == NK_StringNode || rk == NK_SymbolNode ||
                rk == NK_InterpolatedStringNode || rk == NK_ArrayNode || rk == NK_HashNode || rk == NK_RangeNode;
      if (!sub || (ds->bv && !us->bv && !lit)) { wider++; goto report; }
      if (ds->n == us->n && ds->bv == us->bv) same++; else narrower++;
      continue;
    }
  report:
    if (getenv("SPINEL_CLS_FLOW") && sp_streq(getenv("SPINEL_CLS_FLOW"), "wider")) {
      const char *fp = nt_file_path(nt, (int)nt_int(nt, id, "node_file", 0));
      fprintf(stderr, "cls-flow: wider %s:%d %s\n", fp && *fp ? fp : "?", (int)nt_int(nt, id, "node_line", 0),
              nt_str(nt, id, "name") ? nt_str(nt, id, "name") : "?");
    }
  }
  fprintf(stderr, "cls-flow: %ld receivers, ANY unified %ld (%.1f%%) directed %ld (%.1f%%); same %ld, narrower %ld, wider %ld\n",
          calls, any_u, calls ? 100.0 * any_u / calls : 0.0, any_d, calls ? 100.0 * any_d / calls : 0.0, same, narrower, wider);
  fprintf(stderr, "cls-flow-arms: %ld calls a program's method may answer; arms unified %ld directed %ld; at most one arm unified %ld (%.1f%%) directed %ld (%.1f%%)\n",
          ucalls, arms_u, arms_d, mono_u, ucalls ? 100.0 * mono_u / ucalls : 0.0, mono_d, ucalls ? 100.0 * mono_d / ucalls : 0.0);
  free(amemo);
}

/* The facts both walks hold: each is every class a value can be, so a
   class only one of them names is not one the value is. The directed walk
   is the narrower almost everywhere, but past its summary cap (CF_PTS_MAX)
   it joins contents the unified walk keeps apart. */
static void cf_meet(Compiler *c, const int *df, const ClsSet *dp, int dn, int **mf, ClsSet **mp, int *mn, int *mnp) {
  int n = c->cls_fact_n < dn ? c->cls_fact_n : dn;
  int cap = 256, np = 2, hcap = 1024;
  ClsSet *pool = malloc(sizeof *pool * (size_t)cap);
  int *ht = malloc(sizeof(int) * (size_t)hcap), *fact = malloc(sizeof(int) * ((size_t)n + 1));
  if (!pool || !ht || !fact) cf_oom();
  memset(pool, 0, sizeof *pool * 2);
  pool[CF_ALL].all = 1;
  for (int i = 0; i < hcap; i++) ht[i] = -1;
  for (int v = 0; v < n; v++) {
    int u = c->cls_fact[v], d = df[v];
    const ClsSet *us = &c->cls_pool[u], *ds = &dp[d];
    ClsSet m; memset(&m, 0, sizeof m);
    if (u == CF_ALL && d == CF_ALL) { fact[v] = CF_ALL; continue; }
    if (u == CF_ALL) m = *ds;
    else if (d == CF_ALL) m = *us;
    else {
      m.bv = (unsigned char)(us->bv && ds->bv);
      for (int i = 0, j = 0; i < us->n && j < ds->n; ) {
        if (us->cls[i] < ds->cls[j]) i++;
        else if (ds->cls[j] < us->cls[i]) j++;
        else { m.cls[m.n++] = us->cls[i]; i++; j++; }
      }
    }
    if (m.n == 0 && !m.bv) { fact[v] = CF_EMPTY; continue; }
    unsigned h = cf_set_hash(&m) & (unsigned)(hcap - 1);
    while (ht[h] >= 0 && memcmp(&pool[ht[h]], &m, sizeof m)) h = (h + 1) & (unsigned)(hcap - 1);
    if (ht[h] >= 0) { fact[v] = ht[h]; continue; }
    if (np == cap) { cap *= 2; if (!(pool = realloc(pool, sizeof *pool * (size_t)cap))) cf_oom(); }
    pool[np] = m; ht[h] = np; fact[v] = np++;
    if (np * 2 > hcap) {
      hcap *= 2;
      if (!(ht = realloc(ht, sizeof(int) * (size_t)hcap))) cf_oom();
      for (int i = 0; i < hcap; i++) ht[i] = -1;
      for (int k = 2; k < np; k++) {
        unsigned g = cf_set_hash(&pool[k]) & (unsigned)(hcap - 1);
        while (ht[g] >= 0) g = (g + 1) & (unsigned)(hcap - 1);
        ht[g] = k;
      }
    }
  }
  free(ht);
  *mf = fact; *mp = pool; *mn = n; *mnp = np;
}

void an_cls_facts(Compiler *c) {
  const char *flow = getenv("SPINEL_CLS_FLOW");
  int dump = getenv("SPINEL_CLS_FACTS") != NULL;
  /* SPINEL_CLS_FLOW=unified or =directed takes one walk's facts, to tell
     them apart when a program's answer changes */
  if (flow && sp_streq(flow, "unified")) { cf_solve(c, 0, dump); return; }
  if (flow && sp_streq(flow, "directed")) { cf_solve(c, 1, dump); return; }
  /* the facts both walks hold (#8837); any other SPINEL_CLS_FLOW value
     compares the two (cls-flow: lines) */
  cf_solve(c, 1, 0);
  int *df = c->cls_fact, dn = c->cls_fact_n; ClsSet *dp = c->cls_pool;
  c->cls_fact = NULL; c->cls_pool = NULL; c->cls_fact_n = 0; c->ncls_pool = 0;
  cf_solve(c, 0, 0);
  int *mf, mn, mnp; ClsSet *mp;
  cf_meet(c, df, dp, dn, &mf, &mp, &mn, &mnp);
  if (flow) { cf_flow_compare(c, df, dp, dn); fprintf(stderr, "cls-flow: (the facts, the meet of the two:)\n"); cf_flow_compare(c, mf, mp, mn); }
  free(df); free(dp); free(c->cls_fact); free(c->cls_pool);
  c->cls_fact = mf; c->cls_fact_n = mn; c->cls_pool = mp; c->ncls_pool = mnp;
  if (dump) cf_dump_facts(c);
}

/* See compiler.h. */
const ClsSet *cls_fact_node(Compiler *c, int node) {
  if (!c->cls_fact || node < 0 || node >= c->cls_fact_n) return NULL;
  int p = c->cls_fact[node];
  if (p == CF_ALL || p < 0 || p >= c->ncls_pool) return NULL;
  return &c->cls_pool[p];
}

/* See compiler.h. */
int cls_fact_bounded(Compiler *c, int k) {
  if (k < 0 || k >= c->nclasses) return 0;
  ClassInfo *ci = &c->classes[k];
  if (ci->is_native_class || !ci->name) return 0;
  /* a reopened builtin's instances are the runtime's values, an IO's and
     an exception's too */
  if (is_builtin_reopen_name(ci->name) || io_family_class(c, k) || class_has_exc_name(c, k)) return 0;
  if (comp_class_is_module(c, ci)) return 0;
  /* a class with no definition of its own: a Struct's, a singleton's, else
     the runtime's */
  if (ci->def_node < 0 && !ci->is_struct && !ci->is_data && !ci->is_singleton_of) return 0;
  return 1;
}

/* See compiler.h. */
int cls_fact_excludes(Compiler *c, int recv, int k) {
  const ClsSet *s = cls_fact_node(c, recv);
  if (!s || !cls_fact_bounded(c, k)) return 0;
  /* A receiver no value reaches (a call in code nothing runs) excludes no
     class: its call keeps binding every method of the name, as it did
     while the facts were every class. Left unbound, such a method's
     parameters are untyped, and an untyped argument it hands on widens a
     live method's parameter to a box (#9514). */
  if (s->n == 0 && !s->bv) return 0;
  for (int i = 0; i < s->n; i++) if (s->cls[i] == k) return 0;
  return 1;
}

/* See compiler.h. */
int cls_fact_idx(Compiler *c, int node) {
  if (!c->cls_fact || node < 0 || node >= c->cls_fact_n) return -1;
  int p = c->cls_fact[node];
  return p <= 0 || p >= c->ncls_pool ? -1 : p;
}
