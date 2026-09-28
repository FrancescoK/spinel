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
  sp_bool endless;                       /* an argless #cycle: the items are one round, and
                                             #next / #peek start over at their end, so the
                                             enumerator never stops (sp_gc_alloc zero-fills) */
  sp_bool yields_pair;                   /* each item is the two values one step yields
                                             (each_with_index, with_index, each_with_object,
                                             with_object) packed as an Array, which a block
                                             of map and its kin takes spread
                                             (sp_gc_alloc zero-fills) */
  sp_PolyArray *walk_buf;                /* a walker (sp_enum_walker_boxed): the items pulled
                                             so far by an index walk over a generator or
                                             endless source, one at a time; NULL otherwise */
  sp_int walk_next;                      /* the walk's next index: how far it has read */
  sp_bool walk_done;                     /* the source has no more items */
} sp_Enumerator;

#endif
