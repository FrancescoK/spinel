/* sp_string.c -- the cold sp_String in-place mutators (see sp_string.h).
   prepend / insert / replace / dup are off the hot string-building path, so they
   are compiled once here instead of inline in every generated TU. */
#include "sp_string.h"
#include <string.h>

void sp_String_prepend(sp_String*s,const char*t){SP_GC_ROOT(s);SP_GC_ROOT_STR(t);if(!s||!t)return;if(sp_String_is_frozen(s)){sp_raise_frozen_str(s->data);return;}int64_t tl=(int64_t)strlen(t);if(!sp_fd_grow(s,s->len+tl))return;memmove(s->data+tl,s->data,s->len+1);memcpy(s->data,t,tl);s->len+=tl;sp_fd_publish(s);}
/* String#insert(idx, str): insert at idx; negative idx is relative to len+1. */
void sp_String_insert(sp_String*s,int64_t idx,const char*t){SP_GC_ROOT(s);SP_GC_ROOT_STR(t);if(!s||!t)return;if(sp_String_is_frozen(s)){sp_raise_frozen_str(s->data);return;}int64_t tl=(int64_t)strlen(t);if(tl==0)return;if(idx<0)idx+=s->len+1;if(idx<0)idx=0;if(idx>s->len)idx=s->len;if(!sp_fd_grow(s,s->len+tl))return;memmove(s->data+idx+tl,s->data+idx,s->len-idx+1);memcpy(s->data+idx,t,tl);s->len+=tl;sp_fd_publish(s);}
/* String#replace(s): replace entire content. */
void sp_String_replace(sp_String*s,const char*t){SP_GC_ROOT(s);SP_GC_ROOT_STR(t);if(!s||!t)return;if(sp_String_is_frozen(s)){sp_raise_frozen_str(s->data);return;}int64_t tl=(int64_t)strlen(t);if(!sp_fd_grow(s,tl))return;memcpy(s->data,t,tl);s->data[tl]='\0';s->len=tl;sp_fd_publish(s);}
sp_String*sp_String_dup(sp_String*s){SP_GC_ROOT(s);return sp_String_new(s->data);}
/* The first growth past an inline payload (sp_String_new_inline_len) moves
   it to a malloc'd block, which the object now owns: its bytes are counted
   and the finalizer that frees them installed, as sp_String_new_len does
   from the start. The inline room stays part of the object. Rare, and kept
   out of sp_fd_grow so that one still inlines into every append. */
int sp_fd_grow_inline(sp_String *s, int64_t need){
  sp_gc_hdr *h = (sp_gc_hdr *)((char *)s - sizeof(sp_gc_hdr));
  int64_t new_cap = (need * 2) + 16;
  sp_str_lcache_drop(s->data);
  char *raw = (char *)malloc(SP_FD_OVH + new_cap);
  if (!raw) return 0;
  char *data = sp_fd_setup(raw);
  memcpy(data, s->data, (size_t)s->len + 1);
  s->cap = new_cap; s->data = data; sp_fd_own(s);
  h->size += s->cap + SP_FD_OVH; sp_gc_bytes_add(s->cap + SP_FD_OVH);
  if (!h->finalize) { h->finalize = sp_String_fin; sp_slab_set_fin(h); }
  return 1;
}
