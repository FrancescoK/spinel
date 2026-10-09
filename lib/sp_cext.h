#ifndef SP_CEXT_H
#define SP_CEXT_H
#include <ruby.h>
#include "sp_gc.h"

/* Internal bridge. The compiler/recorder will use this only for opted-in
 * extensions; an ordinary generated translation unit never includes it. */
VALUE sp_cext_value(sp_RbVal value);
sp_RbVal sp_cext_rbval(VALUE value);
typedef struct { size_t handles, depth; } sp_cext_arena_mark;
typedef struct { void *entries; size_t length, capacity, depth; } sp_cext_arena_context;
void sp_cext_arena_context_save(sp_cext_arena_context *);
void sp_cext_arena_context_load(const sp_cext_arena_context *);
void sp_cext_arena_context_dispose(sp_cext_arena_context *);
sp_cext_arena_mark sp_cext_arena_enter(void);
sp_cext_arena_mark sp_cext_arena_snapshot(void);
void sp_cext_arena_restore(sp_cext_arena_mark mark);
size_t sp_cext_handle_count(void);
void sp_cext_mark_roots(void);
void sp_cext_sweep_handles(int full);

/* Layout prefix for the compiler's future data classes. The compiler adds
 * Ruby ivars after this prefix and calls these helpers from its scan/finalize
 * functions. The standalone wrapper tests the same lifecycle today. */
typedef struct {
    int cls_id;
    void *cext_data;
    const rb_data_type_t *cext_type;
} sp_cext_data;
void sp_cext_data_scan(void *object);
void sp_cext_data_finalize(void *object);
sp_cext_data *sp_cext_data_new(int cls_id, void *data, const rb_data_type_t *type);
int sp_cext_data_is_kind_of(const sp_cext_data *object, const rb_data_type_t *type);

void sp_cext_exceptions_init(void);
/* Installed by the future compiler bridge for exception classes carrying
 * Ruby ivars. It must allocate the complete generated struct and scan it. */
extern sp_RbVal (*sp_cext_exception_new_fn)(const char *, const char *);


#endif
