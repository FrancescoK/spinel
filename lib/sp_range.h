#ifndef SP_RANGE_H
#define SP_RANGE_H
/* sp_range.h -- Range value-type helpers (see sp_types.h for sp_Range).
 *
 * sp_range_new / _to_ia are called from optcarrot's hot path (range
 * literals / iteration), so they stay `static inline` here -- each
 * generated TU still compiles its own copy, identical to when they lived
 * directly in spinel_rt.h. sp_range_new_step / _eq are trivial
 * single-expression constructors; marking them inline too is effectively a
 * no-op (GCC already inlines such leaf functions at -O2) and keeps the
 * whole small cluster together instead of splitting by a usage-count
 * threshold that could drift under future edits.
 *
 * sp_range_include / sp_range_str see 0 optcarrot uses and have never been
 * inline, so their bodies compile once into libspinel_rt.a (lib/sp_cold.c).
 */
#include "sp_types.h"   /* sp_Range */
#include "sp_array.h"   /* sp_IntArray_from_range / _from_range_step */

static inline sp_Range sp_range_new(sp_int f,sp_int l,sp_int e){sp_Range r;r.first=f;r.last=l;r.excl=e;r.step=0;r.fend=0.0;r.fe=0;return r;}
static inline sp_Range sp_range_new_step(sp_int f,sp_int l,sp_int e,sp_int s){sp_Range r;r.first=f;r.last=l;r.excl=e;r.step=s;r.fend=0.0;r.fe=0;return r;}
/* (1..2.5) / (1...2.5): an Integer begin with a finite Float end. The walk
   stops at the last Integer the end admits -- floor(end), or end - 1 for an
   excluded integral end -- and the end itself is kept for the readers that
   answer it (sp_types.h). An end past sp_int's reach walks without end, as
   an endless range does. */
sp_Range sp_range_new_fend(sp_int f, sp_float e, sp_int x);
/* A use that answers in Integers what CRuby answers with the Float end
   (bsearch, step, rand, a clamp to the end): say so for such a Range. */
void sp_range_fend_unsupported(const char *m);
static inline void sp_range_int_only(sp_Range r, const char *m){if(r.fe)sp_range_fend_unsupported(m);}
/* A Range used as an index span (Array#[], String#[], fill, byteslice, ...):
   CRuby converts each end with to_int, so a Float end truncates toward zero
   and keeps its exclusivity -- a[1...2.5] is a[1...2], a[0..-2.5] a[0..-2] --
   where the walk bounds floor it and fold the exclusivity in. */
static inline sp_Range sp_range_ix(sp_Range r){
  if(!r.fe)return r;
  sp_float t=r.fend!=r.fend?0.0:r.fend>9.2e18?9.2e18:r.fend<-9.2e18?-9.2e18:r.fend;
  sp_Range x=sp_range_new(r.first,(sp_int)t,r.fe==2);
  return x;
}
/* The end as a number for comparisons, and whether it was excluded as written. */
static inline sp_float sp_range_end_num(sp_Range r){return r.fe?r.fend:(sp_float)r.last;}
static inline sp_bool sp_range_excl_end(sp_Range r){return r.fe?r.fe==2:r.excl!=0;}
/* The effective stride: a literal `a..b` range stores 0, which iterates by +1. */
static inline sp_int sp_range_step(sp_Range r){return r.step==0?1:r.step;}
/* Number of elements the range enumerates (0 for an empty one), honoring step. */
static inline sp_int sp_range_count(sp_Range r){
  sp_int s=sp_range_step(r);
  sp_int lastv=r.excl?(r.last-(s>0?1:-1)):r.last;
  sp_int n=(lastv-r.first)/s+1;
  return n<0?0:n;
}
/* Materialize the range into an int array (ascending or descending per step).
   The +1 stride (every literal `a..b` range) keeps the tight from_range loop; a
   real step only appears for downto / explicit step, so it pays the general
   path only then. */
static inline sp_IntArray *sp_range_to_ia(sp_Range r){
  /* an endless range cannot materialize (CRuby raises instead of hanging) */
  if(r.last==INTPTR_MAX)sp_raise_cls("RangeError","cannot convert endless range to an array");
  if(r.first==INTPTR_MIN)sp_raise_cls("TypeError","can't iterate from NilClass");
  sp_int s=sp_range_step(r);
  if(s==1)return sp_IntArray_from_range(r.first,r.last-r.excl);
  return sp_IntArray_from_range_step(r.first,r.last,s,r.excl);
}
/* Last enumerated element (== first for an empty range), and the min/max of the
   enumerated set -- direction-aware, so a descending range reports them right. */
static inline sp_int sp_range_last_elem(sp_Range r){
  sp_int n=sp_range_count(r);
  return n<=0?r.first:r.first+(n-1)*sp_range_step(r);
}
/* min/max of an EMPTY (backwards, or exclusive single-point) range is nil
   (SP_INT_NIL, the nullable-int sentinel) -- CRuby returns nil there. A
   descending step range (5.downto(1)) still enumerates, so only a
   positive-step empty span is nil (#2412). */
static inline sp_int sp_range_min_v(sp_Range r){
  /* a beginless range has no minimum; an endless one's is its begin (#3668) */
  if(r.first==INTPTR_MIN)sp_raise_cls("RangeError","cannot get the minimum of beginless range");
  if(r.last==INTPTR_MAX)return r.first;
  if(sp_range_count(r)<=0)return SP_INT_NIL; sp_int a=r.first,b=sp_range_last_elem(r); return a<b?a:b; }
void sp_range_fend_max_raise(sp_Range r);
static inline sp_int sp_range_max_v(sp_Range r){
  /* a beginless range's maximum is its end; an endless one has none (#3668) */
  /* a Float end (an infinite one too) is the maximum, which this Integer
     reader cannot answer */
  if(r.fe){if(r.first!=INTPTR_MIN&&(sp_float)r.first>r.fend)return SP_INT_NIL;sp_range_fend_max_raise(r);}
  if(r.last==INTPTR_MAX)sp_raise_cls("RangeError","cannot get the maximum of endless range");
  if(r.first==INTPTR_MIN)return r.excl?r.last-1:r.last;
  if(sp_range_count(r)<=0)return SP_INT_NIL; sp_int a=r.first,b=sp_range_last_elem(r); return a>b?a:b; }
/* == compares the ends as numbers ((1..2.0) == (1..2)), eql? by class too */
static inline sp_bool sp_range_eq(sp_Range a,sp_Range b){
  if(!a.fe&&!b.fe)return a.first==b.first&&a.last==b.last&&a.excl==b.excl;
  return a.first==b.first&&sp_range_end_num(a)==sp_range_end_num(b)&&sp_range_excl_end(a)==sp_range_excl_end(b);}
static inline sp_bool sp_range_eql(sp_Range a,sp_Range b){return (a.fe!=0)==(b.fe!=0)&&sp_range_eq(a,b);}

sp_bool sp_range_include(sp_Range *r, sp_int x);
sp_bool sp_range_cover_f(sp_Range *r, sp_float x);
const char *sp_range_str(sp_Range r);
const char *sp_range_inspect(sp_Range r);

/* Float/String Range value-type ops -- 0 optcarrot uses, bodies in
   lib/sp_cold.c (see sp_types.h for sp_FloatRange/sp_StrRange). */
sp_FloatRange sp_frange_new(sp_float f, sp_float l, sp_int e);
sp_FloatRange sp_frange_new_o(sp_float f, sp_float l, sp_int e, sp_int om);
sp_bool sp_frange_cover(sp_FloatRange r, sp_float x);
sp_bool sp_frange_eq(sp_FloatRange a, sp_FloatRange b);
const char *sp_frange_inspect(sp_FloatRange r);
sp_RbVal sp_box_frange(sp_FloatRange v);
sp_float sp_frange_max(sp_FloatRange r);
sp_StrRange sp_srange_new(const char *f, const char *l, sp_int e);
sp_StrArray *sp_srange_to_a(sp_StrRange r);
sp_bool sp_srange_eq(sp_StrRange a, sp_StrRange b);
sp_bool sp_srange_cover(sp_StrRange r, const char *x);
sp_bool sp_srange_include(sp_StrRange r, const char *x);
const char *sp_srange_min_v(sp_StrRange r);
const char *sp_srange_max_v(sp_StrRange r);
const char *sp_srange_to_s(sp_StrRange r);
const char *sp_srange_inspect(sp_StrRange r);
sp_RbVal sp_box_srange(sp_StrRange v);

#endif
