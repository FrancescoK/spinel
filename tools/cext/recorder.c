/* Standalone definition recorder, never part of the program runtime. */
#include "ruby.h"
#include "recorder.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

typedef struct Node {
    char *name, *bytes;
    size_t length;
    int module, frozen, exported;
    char *superclass;
    unsigned index;
    struct Node *next;
    struct Binding *constants;
    int builtin;
} Node;
typedef struct Binding {
    char *name;
    VALUE value;
    struct Binding *next;
} Binding;
static const char *extension;
static FILE *events;
static Node *nodes;
static unsigned node_index;
static unsigned function_index;
static char **symbols;
static size_t symbol_count;
VALUE rb_cObject, rb_cBasicObject, rb_cClass, rb_cModule;
VALUE rb_cString, rb_cArray, rb_cHash, rb_cInteger, rb_cFloat, rb_cIO;
VALUE rb_eException, rb_eStandardError, rb_eRuntimeError, rb_eTypeError;
VALUE rb_eArgError, rb_eRangeError, rb_eNoMemError, rb_eSystemCallError;

static void refuse(const char *api, const char *why) SP_CEXT_NORETURN;
static void refuse(const char *api, const char *why) {
    fprintf(stderr, "spinel cext: %s: %s: %s\n", extension, api, why);
    exit(2);
}
static void *alloc(size_t n) {
    void *p = calloc(1, n);
    if (!p) refuse("recorder", "out of memory");
    return p;
}
static char *copy(const char *s) {
    if (!s) refuse("recorder", "null name");
    char *p = alloc(strlen(s) + 1);
    strcpy(p, s);
    return p;
}
/* Encode bytes explicitly, including NUL and non-ASCII, for a locale- and
 * pointer-independent JSON format. String constants carry hex separately. */
static void quoted(FILE *f, const char *s) {
    if (!s) refuse("recorder", "null metadata string");
    fputc('"', f);
    for (const unsigned char *p = (const unsigned char *)s; *p; p++) {
        if (*p >= 127) refuse("recorder", "only ASCII metadata names are supported");
        if (*p == '"' || *p == '\\') fprintf(f, "\\%c", *p);
        else if (*p < 32 || *p >= 127) fprintf(f, "\\u%04x", *p);
        else fputc(*p, f);
    }
    fputc('"', f);
}
static Node *node(VALUE v, const char *api) {
    if (SPECIAL_CONST_P(v) || !v) refuse(api, "expected a recorded class, module or string");
    for (Node *n = nodes; n; n = n->next) if ((VALUE)n == v) return n;
    refuse(api, "unknown recorder VALUE");
}
static Node *owner(VALUE v, const char *api) {
    Node *n = node(v, api);
    if (!n->name) refuse(api, "expected a recorded class or module");
    return n;
}
static Binding *binding(VALUE o, const char *name) {
    for (Binding *b = owner(o,"definition")->constants; b; b=b->next)
        if (!strcmp(b->name,name)) return b;
    return NULL;
}
static void bind(VALUE o, const char *name, VALUE value) {
    Node *n = owner(o,"definition");
    Binding *b = binding(o,name);
    if (!b) {
        b=alloc(sizeof(*b)); b->name=copy(name);
        b->next=n->constants; n->constants=b;
    }
    b->value=value;
}
static void constant_name(const char *name) {
    if (!name || !*name || *name < 'A' || *name > 'Z')
        refuse("definition", "only ASCII constant names are supported");
    for (const unsigned char *p=(const unsigned char *)name; *p; p++)
        if (!((*p>='A' && *p<='Z') || (*p>='a' && *p<='z') || (*p>='0' && *p<='9') || *p=='_'))
            refuse("definition", "only ASCII constant names are supported");
}
static Node *new_node(void) {
    Node *n = alloc(sizeof(*n));
    n->next = nodes; nodes = n; n->index = node_index++;
    return n;
}
static VALUE named(const char *name, int module) {
    for (Node *n = nodes; n; n = n->next) if (n->name && !strcmp(n->name, name)) {
        if (n->module != module) refuse("rb_define_class/module", "class/module kind mismatch");
        return (VALUE)n;
    }
    Node *n = new_node();
    n->name = copy(name); n->module = module;
    return (VALUE)n;
}
static void event(const char *kind, VALUE v) {
    fputs("{\"kind\":", events); quoted(events, kind);
    fputs(",\"owner\":", events); quoted(events, owner(v, kind)->name);
}
static void field(const char *key, const char *value) {
    fprintf(events, ",\"%s\":", key); quoted(events, value);
}
static void end(void) { fputs("}\n", events); }
void sp_cext_record_begin(const char *name) {
    extension = name;
    events = tmpfile();
    if (!events) refuse("recorder", "cannot create event spool");
#define BUILTIN(var, name, module) var = named(name, module)
    BUILTIN(rb_cBasicObject, "BasicObject", 0); BUILTIN(rb_cObject, "Object", 0);
    BUILTIN(rb_cClass, "Class", 0); BUILTIN(rb_cModule, "Module", 0);
    BUILTIN(rb_cString, "String", 0); BUILTIN(rb_cArray, "Array", 0);
    BUILTIN(rb_cHash, "Hash", 0); BUILTIN(rb_cInteger, "Integer", 0);
    BUILTIN(rb_cFloat, "Float", 0); BUILTIN(rb_cIO, "IO", 0);
    BUILTIN(rb_eException, "Exception", 0); BUILTIN(rb_eStandardError, "StandardError", 0);
    BUILTIN(rb_eRuntimeError, "RuntimeError", 0); BUILTIN(rb_eTypeError, "TypeError", 0);
    BUILTIN(rb_eArgError, "ArgumentError", 0); BUILTIN(rb_eRangeError, "RangeError", 0);
    BUILTIN(rb_eNoMemError, "NoMemoryError", 0); BUILTIN(rb_eSystemCallError, "SystemCallError", 0);
#undef BUILTIN
    for (Node *n=nodes; n; n=n->next) { n->builtin=1; bind(rb_cObject,n->name,(VALUE)n); }
}
void sp_cext_record_finish(void) {
    if (fflush(events) || fseek(events, 0, SEEK_SET)) refuse("recorder", "event spool failed");
    int c;
    while ((c = fgetc(events)) != EOF) fputc(c, stdout);
    if (ferror(events) || fflush(stdout)) refuse("recorder", "output failed");
    fclose(events);
    while (nodes) {
        Node *next = nodes->next;
        while (nodes->constants) {
            Binding *b=nodes->constants; nodes->constants=b->next; free(b->name); free(b);
        }
        free(nodes->name); free(nodes->bytes); free(nodes->superclass); free(nodes); nodes=next;
    }
    for (size_t i=0; i<symbol_count; i++) free(symbols[i]);
    free(symbols);
}
static VALUE define(VALUE outer, const char *name, VALUE super, int module) {
    constant_name(name);
    const char *prefix = owner(outer, "rb_define_class/module")->name;
    size_t size = strlen(prefix) + strlen(name) + 3;
    char *full = alloc(size);
    if (outer == rb_cObject) strcpy(full, name);
    else snprintf(full, size, "%s::%s", prefix, name);
    Binding *existing = binding(outer,name);
    if (existing) {
        Node *n=owner(existing->value,"rb_define_class/module");
        if (n->builtin) refuse("rb_define_class/module","reopening builtin definitions is outside the recorder subset");
        if (strcmp(n->name,full)) refuse("rb_define_class/module","definitions through constant aliases are outside the recorder subset");
    }
    VALUE v = named(full, module); free(full);
    bind(outer,name,v);
    event(module ? "module" : "class", outer); field("name", name);
    field("path", owner(v, "definition")->name);
    if (!module) {
        Node *s = owner(super, "rb_define_class");
        if (s->module) refuse("rb_define_class", "superclass must be a class");
        Node *klass = owner(v,"rb_define_class");
        if (klass->superclass && strcmp(klass->superclass,s->name)) refuse("rb_define_class","superclass mismatch when reopening class");
        if (!klass->superclass) klass->superclass=copy(s->name);
        field("superclass", s->name);
    }
    end(); return v;
}
VALUE rb_define_class(const char *n, VALUE s) { return define(rb_cObject, n, s, 0); }
VALUE rb_define_class_under(VALUE o, const char *n, VALUE s) { return define(o, n, s, 0); }
VALUE rb_define_module(const char *n) { return define(rb_cObject, n, Qnil, 1); }
VALUE rb_define_module_under(VALUE o, const char *n) { return define(o, n, Qnil, 1); }
static void method(VALUE o, const char *n, VALUE (*f)(ANYARGS), int a, const char *scope, const char *visibility) {
    if (!f || a < -2) refuse("rb_define_method", "unsupported function or arity");
    event("method", o); field("name", n); field("scope", scope); field("visibility", visibility);
    fprintf(events, ",\"arity\":%d,\"function\":%u", a, function_index++); end();
}
void rb_define_method(VALUE o, const char *n, VALUE (*f)(ANYARGS), int a) { method(o,n,f,a,"instance","public"); }
void rb_define_private_method(VALUE o, const char *n, VALUE (*f)(ANYARGS), int a) { method(o,n,f,a,"instance","private"); }
void rb_define_singleton_method(VALUE o, const char *n, VALUE (*f)(ANYARGS), int a) { method(o,n,f,a,"singleton","public"); }
void rb_define_module_function(VALUE o, const char *n, VALUE (*f)(ANYARGS), int a) {
    method(o,n,f,a,"instance","private"); method(o,n,f,a,"singleton","public");
}
void rb_define_alloc_func(VALUE o, VALUE (*f)(VALUE)) {
    if (!f) refuse("rb_define_alloc_func", "null allocator");
    event("allocator",o); fprintf(events, ",\"function\":%u", function_index++); end();
}
void rb_define_alias(VALUE o, const char *n, const char *old) { event("alias",o); field("name",n); field("original",old); end(); }
void rb_define_attr(VALUE o, const char *n, int r, int w) {
    event("attribute",o); field("name",n); fprintf(events, ",\"read\":%s,\"write\":%s",r?"true":"false",w?"true":"false"); end();
}
void rb_include_module(VALUE o, VALUE m) { event("include",o); field("module",owner(m,"rb_include_module")->name); end(); }
void rb_extend_object(VALUE o, VALUE m) { event("extend",o); field("module",owner(m,"rb_extend_object")->name); end(); }
ID rb_intern(const char *s) {
    for (size_t i=0;i<symbol_count;i++) if (!strcmp(s,symbols[i])) return i+1;
    char **next = realloc(symbols,(symbol_count+1)*sizeof(*next));
    if (!next) refuse("rb_intern","out of memory");
    symbols=next; symbols[symbol_count++]=copy(s); return symbol_count;
}
const char *rb_id2name(ID id) { if (!id || id>symbol_count) refuse("rb_id2name","unknown ID"); return symbols[id-1]; }
VALUE rb_str_new(const char *s, long len) {
    if (len < 0 || (!s && len)) refuse("rb_str_new","invalid string");
    Node *n=new_node(); n->length=(size_t)len; n->bytes=alloc((size_t)len+1);
    if (len) memcpy(n->bytes,s,(size_t)len); return (VALUE)n;
}
VALUE rb_str_new_cstr(const char *s) { return rb_str_new(s,(long)strlen(s)); }
VALUE rb_str_freeze(VALUE v) { Node *n = node(v,"rb_str_freeze"); if (n->name) refuse("rb_str_freeze","expected string"); if (n->exported && !n->frozen) refuse("rb_str_freeze","freeze string constants before defining them"); n->frozen=1; return v; }
void rb_define_const(VALUE o, const char *n, VALUE v) {
    constant_name(n);
    bind(o,n,v);
    event("constant",o); field("name",n); fputs(",\"value\":{\"type\":",events);
    if (FIXNUM_P(v)) { quoted(events,"integer"); fprintf(events,",\"value\":%lld",(long long)FIX2LONG(v)); }
    else if (v==Qnil) quoted(events,"nil");
    else if (v==Qtrue || v==Qfalse) { quoted(events,"boolean"); fprintf(events,",\"value\":%s",v==Qtrue?"true":"false"); }
    else if (SYMBOL_P(v)) { quoted(events,"symbol"); field("value",rb_id2name(SYM2ID(v))); }
    else {
        Node *x=node(v,"rb_define_const"); x->exported=1;
        if (x->name) { quoted(events,"reference"); field("value",x->name); }
        else { quoted(events,"string"); fputs(",\"hex\":\"",events); for(size_t i=0;i<x->length;i++) fprintf(events,"%02x",(unsigned char)x->bytes[i]); fputc('"',events); fprintf(events, ",\"object\":%u,\"frozen\":%s", x->index, x->frozen ? "true" : "false"); }
    }
    fputc('}',events); end();
}
void rb_gc_register_address(VALUE *v) { (void)v; }
void rb_gc_unregister_address(VALUE *v) { (void)v; }
void rb_global_variable(VALUE *v) { (void)v; }
#define DENIED(api) refuse(api,"Ruby execution or runtime state is not allowed during Init")
VALUE rb_funcall(VALUE v, ID id, int argc, ...) { (void)v;(void)id;(void)argc;DENIED("rb_funcall"); }
VALUE rb_const_get(VALUE v, ID id) { (void)v;(void)id;DENIED("rb_const_get"); }
VALUE rb_eval_string(const char *s) { (void)s;DENIED("rb_eval_string"); }
void rb_raise(VALUE v,const char *s,...) { (void)v;(void)s;DENIED("rb_raise"); }
void rb_exc_raise(VALUE v) { (void)v;DENIED("rb_exc_raise"); }
VALUE rb_errinfo(void) { DENIED("rb_errinfo"); }
void rb_set_errinfo(VALUE v) { (void)v;DENIED("rb_set_errinfo"); }

VALUE rb_protect(VALUE (*f)(VALUE), VALUE a, int *s) { (void)f;(void)a;(void)s;DENIED("rb_protect"); }
VALUE rb_ensure(VALUE (*f)(VALUE),VALUE a,VALUE (*g)(VALUE),VALUE b) { (void)f;(void)a;(void)g;(void)b;DENIED("rb_ensure"); }
VALUE rb_rescue(VALUE (*f)(VALUE),VALUE a,VALUE (*g)(VALUE,VALUE),VALUE b) { (void)f;(void)a;(void)g;(void)b;DENIED("rb_rescue"); }
VALUE rb_rescue2(VALUE (*f)(VALUE),VALUE a,VALUE (*g)(VALUE,VALUE),VALUE b,...) { (void)f;(void)a;(void)g;(void)b;DENIED("rb_rescue2"); }
VALUE rb_exc_new(VALUE v,const char *s,long n) { (void)v;(void)s;(void)n;DENIED("rb_exc_new"); }
VALUE rb_exc_new_cstr(VALUE v,const char *s) { (void)v;(void)s;DENIED("rb_exc_new_cstr"); }
void rb_jump_tag(int n) { (void)n;DENIED("rb_jump_tag"); }
void rb_sys_fail(const char *s) { (void)s;DENIED("rb_sys_fail"); }
void rb_bug(const char *s,...) { (void)s;DENIED("rb_bug"); }
void rb_fatal(const char *s,...) { (void)s;DENIED("rb_fatal"); }
void rb_gc_mark(VALUE v) { (void)v;DENIED("rb_gc_mark"); }
void rb_gc_mark_movable(VALUE v) { (void)v;DENIED("rb_gc_mark_movable"); }
VALUE rb_gc_location(VALUE v) { (void)v;DENIED("rb_gc_location"); }
