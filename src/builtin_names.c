/* builtin_names.c -- the families of builtin method names (builtin_names.h).
   Each family is spelled once here; the order is the order its compares run
   in, the one most of the replaced chains used. */
#include "types.h"
#include "builtin_names.h"

int is_call_alias(const char *n) {
  return sp_streq(n, "call") || sp_streq(n, "()") || sp_streq(n, "[]");
}

int is_kind_query(const char *n) {
  return sp_streq(n, "is_a?") || sp_streq(n, "kind_of?") || sp_streq(n, "instance_of?");
}

int is_round_family(const char *n) {
  return sp_streq(n, "round") || sp_streq(n, "ceil") || sp_streq(n, "floor") || sp_streq(n, "truncate");
}

int is_push_alias(const char *n) {
  return sp_streq(n, "push") || sp_streq(n, "<<") || sp_streq(n, "append");
}

int is_bit_op(const char *n) {
  return sp_streq(n, "&") || sp_streq(n, "|") || sp_streq(n, "^");
}

int is_basic_arith(const char *n) {
  return sp_streq(n, "+") || sp_streq(n, "-") || sp_streq(n, "*") || sp_streq(n, "/");
}

int is_object_root(const char *n) {
  return sp_streq(n, "Object") || sp_streq(n, "BasicObject") || sp_streq(n, "Kernel");
}

int is_send_family(const char *n) {
  return sp_streq(n, "send") || sp_streq(n, "__send__") || sp_streq(n, "public_send");
}

int is_name_reader(const char *n) {
  return sp_streq(n, "name") || sp_streq(n, "to_s") || sp_streq(n, "inspect");
}

int is_tap_alias(const char *n) {
  return sp_streq(n, "tap") || sp_streq(n, "then") || sp_streq(n, "yield_self");
}

int is_quantifier(const char *n) {
  return sp_streq(n, "all?") || sp_streq(n, "any?") || sp_streq(n, "none?") || sp_streq(n, "one?");
}

int is_set_op(const char *n) {
  return sp_streq(n, "&") || sp_streq(n, "intersection") || sp_streq(n, "|") || sp_streq(n, "union") ||
         sp_streq(n, "-") || sp_streq(n, "difference");
}

int is_combination_family(const char *n) {
  return sp_streq(n, "combination") || sp_streq(n, "permutation") ||
         sp_streq(n, "repeated_combination") || sp_streq(n, "repeated_permutation");
}

int is_visibility_name(const char *n) {
  return sp_streq(n, "private") || sp_streq(n, "protected") || sp_streq(n, "public");
}
