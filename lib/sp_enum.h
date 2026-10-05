/* sp_enum.h -- the Enumerator handle (cursor/generator ops in lib/sp_cold.c).
 *
 * Two flavors: a materialized snapshot (items + cursor, from a collection's
 * blockless #each) or a fiber-backed generator (Enumerator.new { |y| ... },
 * where `y << v` is a Fiber.yield). The fiber is created lazily on first
 * #next and re-created on #rewind. */
#ifndef SP_ENUM_H
#define SP_ENUM_H

#include "sp_alloc.h"
#include "sp_fiber.h"

#define SP_PAIR_EACH   1
#define SP_PAIR_PACKED 2

/* The Array a generator step that yields several values packs them in: an
   ordinary poly array, told apart by its scan function so a generator that
   also yields single values (an Array among them) keeps each step's arity. */
void sp_PolyArray_pack_scan(void *p);
sp_PolyArray *sp_PolyArray_new_pack(void);
static inline sp_bool sp_poly_is_pack(sp_RbVal v) {
  return v.tag == SP_TAG_OBJ && v.cls_id == SP_BUILTIN_POLY_ARRAY && v.v.p &&
         ((sp_gc_hdr *)((char *)v.v.p - sizeof(sp_gc_hdr)))->scan == sp_PolyArray_pack_scan;
}

/* A generator step that yields no value (`y.yield`, `y.yield(*[])`): nil to a
   reader of the item, and no values to a `|*r|` block. The mark rides in the
   nil's cls_id, which nothing else reads. */
static inline sp_RbVal sp_box_empty_step(void) {
  sp_RbVal r = sp_box_nil(); r.cls_id = 1; return r;
}
static inline sp_bool sp_poly_is_empty_step(sp_RbVal v) {
  return v.tag == SP_TAG_NIL && v.cls_id == 1;
}

typedef struct {
  sp_PolyArray *items; sp_int cursor;   /* materialized mode (items != NULL) */
  void (*gen)(sp_Fiber *);                /* generator body (fiber mode, gen != NULL) */
  void *gen_cap;                          /* captures, passed via fiber user_data */
  sp_Fiber *fib;                          /* current generator fiber (lazy) */
  sp_bool peeked; sp_RbVal peek_val;     /* #peek lookahead cache */
  sp_RbVal size;                          /* #size for a generator: a value, a
                                             callable (Proc), or nil. Unused by
                                             the materialized path (items->len). */
  sp_RbVal feed; sp_bool has_feed;       /* #feed: value returned by the next Fiber.yield */
  sp_RbVal gen_result;                    /* generator body's return -> StopIteration#result */
  sp_RbVal source;                        /* the iterated receiver -> materialized StopIteration#result */
  sp_bool has_src;                       /* source is set, even to nil: `nil.then`'s receiver IS
                                             nil, and #inspect must not read that as "no source"
                                             and fall back to the items (sp_gc_alloc zero-fills) */
  const char *meth;                       /* creating method name, for #inspect ("each", ...):
                                             an SPL literal or a GC-traced heap label */
  sp_bool gen_label;                     /* #inspect as a Generator wrapper (chunk_while & co.):
                                             the items are an eager snapshot, but CRuby shows
                                             #<Enumerator: #<Enumerator::Generator:0x..>:each> */
  sp_bool frozen;                        /* Object#freeze observed (sp_gc_alloc zero-fills) */
  sp_bool is_chain;                      /* built by Enumerable#chain / Enumerator#+: the items
                                             are the concatenated sources, and #class reports
                                             Enumerator::Chain (sp_gc_alloc zero-fills) */
  sp_bool is_product;                    /* built by Enumerator.product / Enumerator::Product.new:
                                             the items are the tuples, `source` the factors, and
                                             #class reports Enumerator::Product (zero-filled) */
  sp_bool endless;                       /* an argless #cycle: the items are one round, and
                                             #next / #peek start over at their end, so the
                                             enumerator never stops (sp_gc_alloc zero-fills) */
  sp_bool is_bsearch;                    /* Array#bsearch enum_for: items are candidates,
                                             with the block result steering the search */
  sp_int bsearch_lo, bsearch_hi, bsearch_mid;
  sp_bool bsearch_waiting;
  sp_RbVal bsearch_result;
  unsigned char yields_pair;             /* SP_PAIR_EACH: each item is the two values one step
                                             yields (each_with_index, with_index,
                                             each_with_object, with_object) packed as an Array,
                                             which a block of map and its kin takes spread;
                                             SP_PAIR_PACKED: only the items packed by a
                                             generator step that yielded several values
                                             (sp_PolyArray_new_pack) are (sp_gc_alloc
                                             zero-fills) */
  sp_PolyArray *walk_buf;                /* a walker (sp_enum_walker_boxed): the items pulled
                                             so far by an index walk over a generator or
                                             endless source, one at a time; NULL otherwise */
  sp_int walk_next;                      /* the walk's next index: how far it has read */
  sp_bool walk_done;                     /* the source has no more items */
} sp_Enumerator;

#endif
