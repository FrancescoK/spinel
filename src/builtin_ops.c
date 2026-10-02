/* builtin_ops.c -- the builtin method rows (see builtin_ops.h). */

#include <stdlib.h>
#include <string.h>
#include "builtin_ops.h"

/* Rows grouped by receiver kind. Within a kind the order does not matter:
   lookups go through the sorted index below. */
static const BuiltinOp bop_rows[] = {
  /* Process::Tms: four cumulative CPU times, all Float (#3044), fields of
     the by-value struct */
  { TY_TMS, "utime",  0, 0, BF_ANY, TY_FLOAT, BOPE_TEMPLATE, "($r).utime" },
  { TY_TMS, "stime",  0, 0, BF_ANY, TY_FLOAT, BOPE_TEMPLATE, "($r).stime" },
  { TY_TMS, "cutime", 0, 0, BF_ANY, TY_FLOAT, BOPE_TEMPLATE, "($r).cutime" },
  { TY_TMS, "cstime", 0, 0, BF_ANY, TY_FLOAT, BOPE_TEMPLATE, "($r).cstime" },

  /* Process::Status (sp_ProcessStatus *). The runtime helpers take the
     status word and answer unboxed scalars, -1 being nil for exitstatus
     and termsig; the call site boxes by the inferred type. #class and
     #inspect type as String here, as they always have. */
  { TY_PROCESS_STATUS, "signaled?",  0, 0, BF_ANY, TY_BOOL,   BOPE_TEMPLATE, "sp_process_status_signaled_p(($r)->status)" },
  { TY_PROCESS_STATUS, "exited?",    0, 0, BF_ANY, TY_BOOL,   BOPE_TEMPLATE, "sp_process_status_exited_p(($r)->status)" },
  { TY_PROCESS_STATUS, "coredump?",  0, 0, BF_ANY, TY_BOOL,   BOPE_TEMPLATE, "sp_process_status_coredump_p(($r)->status)" },
  { TY_PROCESS_STATUS, "success?",   0, 0, BF_ANY, TY_POLY,   BOPE_PSTATUS_SUCCESS },
  { TY_PROCESS_STATUS, "exitstatus", 0, 0, BF_ANY, TY_INT,    BOPE_TEMPLATE, "sp_process_status_exitstatus(($r)->status)" },
  { TY_PROCESS_STATUS, "termsig",    0, 0, BF_ANY, TY_INT,    BOPE_TEMPLATE, "sp_process_status_termsig(($r)->status)" },
  { TY_PROCESS_STATUS, "pid",        0, 0, BF_ANY, TY_INT,    BOPE_TEMPLATE, "($r)->pid" },
  { TY_PROCESS_STATUS, "to_s",       0, 0, BF_ANY, TY_STRING, BOPE_TEMPLATE, "sp_process_status_to_s(($r)->status, 0)" },
  { TY_PROCESS_STATUS, "inspect",    0, 0, BF_ANY, TY_STRING, BOPE_TEMPLATE, "sp_process_status_to_s(($r)->status, 1)" },
  { TY_PROCESS_STATUS, "class",      0, 0, BF_ANY, TY_STRING, BOPE_TEMPLATE, "((sp_Class){(sp_int)-163, NULL})" },
  { TY_PROCESS_STATUS, "==",         0, 0, BF_ANY, TY_BOOL,    BOPE_PSTATUS_EQ },
  { TY_PROCESS_STATUS, "eql?",       0, 0, BF_ANY, TY_UNKNOWN, BOPE_PSTATUS_EQ },

  /* Socket::Option. Spinel carries the integer-valued options only, so the
     readers answer through the int the option holds. #class is typed here
     and emitted by the generic class arm. */
  { TY_SOCKOPT, "int",     0, 0, BF_ANY, TY_INT,    BOPE_TEMPLATE, "($r)->value" },
  { TY_SOCKOPT, "bool",    0, 0, BF_ANY, TY_BOOL,   BOPE_TEMPLATE, "(($r)->value != 0)" },
  { TY_SOCKOPT, "level",   0, 0, BF_ANY, TY_INT,    BOPE_TEMPLATE, "($r)->level" },
  { TY_SOCKOPT, "optname", 0, 0, BF_ANY, TY_INT,    BOPE_TEMPLATE, "($r)->optname" },
  { TY_SOCKOPT, "family",  0, 0, BF_ANY, TY_INT,    BOPE_TEMPLATE, "($r)->family" },
  { TY_SOCKOPT, "inspect", 0, 0, BF_ANY, TY_STRING, BOPE_TEMPLATE, "sp_sockopt_inspect($r)" },
  { TY_SOCKOPT, "to_s",    0, 0, BF_ANY, TY_STRING, BOPE_TEMPLATE, "sp_sockopt_inspect($r)" },
  { TY_SOCKOPT, "class",   0, 0, BF_ANY, TY_CLASS,  BOPE_NONE },

  /* Addrinfo: the value is immutable, so each reader is a field read. The
     family tests use strcmp, not sp_str_eq: sp_str_eq confirms a hit by
     comparing byte lengths, and the length of a bare C literal is read
     from its s[-1] marker, out of bounds; afname is NUL-free. */
  { TY_ADDRINFO, "ip_address",   0, 0, BF_ANY, TY_STRING, BOPE_TEMPLATE, "($r)->ip" },
  { TY_ADDRINFO, "unix_path",    0, 0, BF_ANY, TY_STRING, BOPE_TEMPLATE, "($r)->ip" },
  { TY_ADDRINFO, "afamily_name", 0, 0, BF_ANY, TY_STRING, BOPE_TEMPLATE, "($r)->afname" },
  { TY_ADDRINFO, "afamily",      0, 0, BF_ANY, TY_INT,    BOPE_TEMPLATE, "($r)->afamily" },
  { TY_ADDRINFO, "pfamily",      0, 0, BF_ANY, TY_INT,    BOPE_TEMPLATE, "($r)->afamily" },
  { TY_ADDRINFO, "ip_port",      0, 0, BF_ANY, TY_INT,    BOPE_TEMPLATE, "($r)->port" },
  { TY_ADDRINFO, "socktype",     0, 0, BF_ANY, TY_INT,    BOPE_TEMPLATE, "($r)->socktype" },
  { TY_ADDRINFO, "protocol",     0, 0, BF_ANY, TY_INT,    BOPE_TEMPLATE, "($r)->protocol" },
  { TY_ADDRINFO, "ipv4?",        0, 0, BF_ANY, TY_BOOL,   BOPE_TEMPLATE, "(($r)->afname && strcmp(($r)->afname, \"AF_INET\") == 0)" },
  { TY_ADDRINFO, "ipv6?",        0, 0, BF_ANY, TY_BOOL,   BOPE_TEMPLATE, "(($r)->afname && strcmp(($r)->afname, \"AF_INET6\") == 0)" },
  { TY_ADDRINFO, "unix?",        0, 0, BF_ANY, TY_BOOL,   BOPE_TEMPLATE, "(($r)->afname && strcmp(($r)->afname, \"AF_UNIX\") == 0)" },
  { TY_ADDRINFO, "ip?",          0, 0, BF_ANY, TY_BOOL,   BOPE_TEMPLATE, "(!(($r)->afname && strcmp(($r)->afname, \"AF_UNIX\") == 0))" },
  { TY_ADDRINFO, "to_sockaddr",  0, 0, BF_ANY, TY_STRING, BOPE_TEMPLATE, "sp_addrinfo_to_sockaddr($r)" },
  { TY_ADDRINFO, "inspect",      0, 0, BF_ANY, TY_STRING, BOPE_TEMPLATE, "sp_addrinfo_inspect($r)" },
  { TY_ADDRINFO, "to_s",         0, 0, BF_ANY, TY_STRING, BOPE_TEMPLATE, "sp_addrinfo_inspect($r)" },
  { TY_ADDRINFO, "class",        0, 0, BF_ANY, TY_CLASS,  BOPE_NONE },

  /* Time (sp_Time, a value): readers of the receiver, rendered once. Each
     ignores its arguments, as the arms they replace did; #class is typed as
     String here, as it always has been. */
  { TY_TIME, "year",       0, 127, BF_ANY, TY_INT,    BOPE_TEMPLATE, "sp_time_year($r)" },
  { TY_TIME, "mon",        0, 127, BF_ANY, TY_INT,    BOPE_TEMPLATE, "sp_time_mon($r)" },
  { TY_TIME, "month",      0, 127, BF_ANY, TY_INT,    BOPE_TEMPLATE, "sp_time_mon($r)" },
  { TY_TIME, "day",        0, 127, BF_ANY, TY_INT,    BOPE_TEMPLATE, "sp_time_mday($r)" },
  { TY_TIME, "mday",       0, 127, BF_ANY, TY_INT,    BOPE_TEMPLATE, "sp_time_mday($r)" },
  { TY_TIME, "hour",       0, 127, BF_ANY, TY_INT,    BOPE_TEMPLATE, "sp_time_hour($r)" },
  { TY_TIME, "min",        0, 127, BF_ANY, TY_INT,    BOPE_TEMPLATE, "sp_time_min($r)" },
  { TY_TIME, "sec",        0, 127, BF_ANY, TY_INT,    BOPE_TEMPLATE, "sp_time_sec($r)" },
  { TY_TIME, "wday",       0, 127, BF_ANY, TY_INT,    BOPE_TEMPLATE, "sp_time_wday($r)" },
  { TY_TIME, "yday",       0, 127, BF_ANY, TY_INT,    BOPE_TEMPLATE, "sp_time_yday($r)" },
  { TY_TIME, "to_i",       0, 127, BF_ANY, TY_INT,    BOPE_TEMPLATE, "($r).tv_sec" },
  { TY_TIME, "tv_sec",     0, 127, BF_ANY, TY_INT,    BOPE_TEMPLATE, "($r).tv_sec" },
  { TY_TIME, "tv_usec",    0, 127, BF_ANY, TY_INT,    BOPE_TEMPLATE, "((sp_int)($r).tv_nsec / 1000)" },
  { TY_TIME, "usec",       0, 127, BF_ANY, TY_INT,    BOPE_TEMPLATE, "((sp_int)($r).tv_nsec / 1000)" },
  { TY_TIME, "tv_nsec",    0, 127, BF_ANY, TY_INT,    BOPE_TEMPLATE, "((sp_int)($r).tv_nsec)" },
  { TY_TIME, "nsec",       0, 127, BF_ANY, TY_INT,    BOPE_TEMPLATE, "((sp_int)($r).tv_nsec)" },
  { TY_TIME, "utc?",       0, 127, BF_ANY, TY_BOOL,   BOPE_TEMPLATE, "(($r).is_utc == 1)" },
  { TY_TIME, "gmt?",       0, 127, BF_ANY, TY_BOOL,   BOPE_TEMPLATE, "(($r).is_utc == 1)" },
  { TY_TIME, "dst?",       0, 127, BF_ANY, TY_BOOL,   BOPE_TEMPLATE, "(sp_time_isdst($r) != 0)" },
  { TY_TIME, "isdst",      0, 127, BF_ANY, TY_BOOL,   BOPE_TEMPLATE, "(sp_time_isdst($r) != 0)" },
  { TY_TIME, "utc_offset", 0, 127, BF_ANY, TY_INT,    BOPE_TEMPLATE, "sp_time_utc_offset($r)" },
  { TY_TIME, "gmt_offset", 0, 127, BF_ANY, TY_INT,    BOPE_TEMPLATE, "sp_time_utc_offset($r)" },
  { TY_TIME, "gmtoff",     0, 127, BF_ANY, TY_INT,    BOPE_TEMPLATE, "sp_time_utc_offset($r)" },
  { TY_TIME, "inspect",    0, 127, BF_ANY, TY_STRING, BOPE_TEMPLATE, "sp_time_inspect_v($r)" },
  { TY_TIME, "to_s",       0, 127, BF_ANY, TY_STRING, BOPE_TEMPLATE, "sp_time_to_s_v($r)" },
  { TY_TIME, "zone",       0, 127, BF_ANY, TY_STRING, BOPE_TEMPLATE, "sp_time_zone($r)" },
  { TY_TIME, "class",      0, 127, BF_ANY, TY_STRING, BOPE_TEMPLATE, "((sp_Class){(sp_int)-1, SPL(\"Time\")})" },
  { TY_TIME, "getgm",      0, 127, BF_ANY, TY_TIME,   BOPE_TEMPLATE, "sp_time_utc($r)" },
  { TY_TIME, "sunday?",    0, 127, BF_ANY, TY_BOOL,   BOPE_TEMPLATE, "(sp_time_wday($r) == 0)" },
  { TY_TIME, "monday?",    0, 127, BF_ANY, TY_BOOL,   BOPE_TEMPLATE, "(sp_time_wday($r) == 1)" },
  { TY_TIME, "tuesday?",   0, 127, BF_ANY, TY_BOOL,   BOPE_TEMPLATE, "(sp_time_wday($r) == 2)" },
  { TY_TIME, "wednesday?", 0, 127, BF_ANY, TY_BOOL,   BOPE_TEMPLATE, "(sp_time_wday($r) == 3)" },
  { TY_TIME, "thursday?",  0, 127, BF_ANY, TY_BOOL,   BOPE_TEMPLATE, "(sp_time_wday($r) == 4)" },
  { TY_TIME, "friday?",    0, 127, BF_ANY, TY_BOOL,   BOPE_TEMPLATE, "(sp_time_wday($r) == 5)" },
  { TY_TIME, "saturday?",  0, 127, BF_ANY, TY_BOOL,   BOPE_TEMPLATE, "(sp_time_wday($r) == 6)" },
  { TY_TIME, "asctime",    0, 127, BF_ANY, TY_STRING, BOPE_TEMPLATE, "sp_time_strftime($r, \"%a %b %e %H:%M:%S %Y\")" },
  { TY_TIME, "ctime",      0, 127, BF_ANY, TY_STRING, BOPE_TEMPLATE, "sp_time_strftime($r, \"%a %b %e %H:%M:%S %Y\")" },

  /* MatchData (sp_MatchData *, NULL for no match): the readers of the
     receiver, rendered once; the BOPE_NONE rows type calls whose arms render
     an argument and stay in emit_value_recv_call. #[] and
     named_captures(symbolize_names:) are typed by the argument there. A
     name with no row is refused unless Object is reopened with it. */
  { TY_MATCHDATA, "inspect",          0,   0, BF_ANY, TY_STRING,         BOPE_TEMPLATE, "sp_MatchData_inspect($r)" },  /* #2500 */
  { TY_MATCHDATA, "to_s",             0, 127, BF_ANY, TY_STRING,         BOPE_TEMPLATE, "sp_MatchData_to_s($r)" },
  { TY_MATCHDATA, "pre_match",        0, 127, BF_ANY, TY_STRING,         BOPE_TEMPLATE, "sp_MatchData_pre_match($r)" },
  { TY_MATCHDATA, "post_match",       0, 127, BF_ANY, TY_STRING,         BOPE_TEMPLATE, "sp_MatchData_post_match($r)" },
  { TY_MATCHDATA, "string",           0,   0, BF_ANY, TY_STRING,         BOPE_TEMPLATE, "sp_MatchData_string($r)" },
  { TY_MATCHDATA, "string",           1, 127, BF_ANY, TY_STRING,         BOPE_NONE },
  { TY_MATCHDATA, "names",            0,   0, BF_ANY, TY_STR_ARRAY,      BOPE_TEMPLATE, "sp_MatchData_names($r)" },
  { TY_MATCHDATA, "names",            1, 127, BF_ANY, TY_STR_ARRAY,      BOPE_NONE },
  { TY_MATCHDATA, "regexp",           0,   0, BF_ANY, TY_REGEX,          BOPE_TEMPLATE, "((mrb_regexp_pattern *)($r)->pat)" },  /* #2499 */
  { TY_MATCHDATA, "length",           0,   0, BF_ANY, TY_INT,            BOPE_TEMPLATE, "sp_MatchData_length($r)" },
  { TY_MATCHDATA, "length",           1, 127, BF_ANY, TY_INT,            BOPE_NONE },
  { TY_MATCHDATA, "size",             0,   0, BF_ANY, TY_INT,            BOPE_TEMPLATE, "sp_MatchData_length($r)" },
  { TY_MATCHDATA, "size",             1, 127, BF_ANY, TY_INT,            BOPE_NONE },
  { TY_MATCHDATA, "captures",         0, 127, BF_ANY, TY_POLY_ARRAY,     BOPE_TEMPLATE, "sp_MatchData_captures($r)" },
  { TY_MATCHDATA, "to_a",             0, 127, BF_ANY, TY_POLY_ARRAY,     BOPE_TEMPLATE, "sp_MatchData_to_a($r)" },
  { TY_MATCHDATA, "deconstruct",      0,   0, BF_ANY, TY_POLY_ARRAY,     BOPE_TEMPLATE, "sp_MatchData_captures($r)" },
  { TY_MATCHDATA, "values_at",        0,   0, BF_ANY, TY_POLY_ARRAY,     BOPE_TEMPLATE, "((void)($r), sp_PolyArray_new())" },  /* selects nothing (#3846) */
  { TY_MATCHDATA, "values_at",        1, 127, BF_ANY, TY_POLY_ARRAY,     BOPE_NONE },
  { TY_MATCHDATA, "named_captures",   0,   0, BF_ANY, TY_STR_POLY_HASH,  BOPE_TEMPLATE, "sp_md_named_captures($r)" },
  { TY_MATCHDATA, "named_captures",   2, 127, BF_ANY, TY_STR_POLY_HASH,  BOPE_NONE },
  { TY_MATCHDATA, "nil?",             0, 127, BF_ANY, TY_BOOL,           BOPE_TEMPLATE, "($r == 0)" },
  { TY_MATCHDATA, "hash",             0,   0, BF_ANY, TY_UNKNOWN,        BOPE_TEMPLATE, "sp_MatchData_hash($r)" },  /* content-based (#3014) */
  { TY_MATCHDATA, "frozen?",          0,   0, BF_ANY, TY_UNKNOWN,        BOPE_TEMPLATE, "sp_gc_is_frozen((void *)($r))" },  /* the bit freeze sets (#3638) */
  { TY_MATCHDATA, "freeze",           0,   0, BF_ANY, TY_UNKNOWN,        BOPE_TEMPLATE, "((sp_MatchData *)sp_gc_freeze((void *)($r)))" },
  { TY_MATCHDATA, "==",               1,   1, BF_ANY, TY_BOOL,           BOPE_NONE },
  { TY_MATCHDATA, "eql?",             1,   1, BF_ANY, TY_BOOL,           BOPE_NONE },
  { TY_MATCHDATA, "match",            1,   1, BF_ANY, TY_STRING,         BOPE_NONE },
  { TY_MATCHDATA, "match_length",     1,   1, BF_ANY, TY_POLY,           BOPE_NONE },
  { TY_MATCHDATA, "deconstruct_keys", 1,   1, BF_ANY, TY_SYM_POLY_HASH,  BOPE_NONE },
  { TY_MATCHDATA, "begin",            0, 127, BF_ANY, TY_INT,            BOPE_NONE },
  { TY_MATCHDATA, "end",              0, 127, BF_ANY, TY_INT,            BOPE_NONE },
  { TY_MATCHDATA, "bytebegin",        0, 127, BF_ANY, TY_INT,            BOPE_NONE },
  { TY_MATCHDATA, "byteend",          0, 127, BF_ANY, TY_INT,            BOPE_NONE },
  { TY_MATCHDATA, "offset",           0, 127, BF_ANY, TY_INT_ARRAY,      BOPE_NONE },
  { TY_MATCHDATA, "byteoffset",       0, 127, BF_ANY, TY_INT_ARRAY,      BOPE_NONE },

  /* Complex: result kinds only for now; emission stays in emit_call_body.
     real/imaginary/abs box to poly, each component keeping its CRuby class.
     % and modulo raise NoMethodError and are typed Complex only so the
     raise has a consistent slot (#2618). nonzero? is self or nil;
     infinite? and <=> answer nil through an Integer sentinel. */
  { TY_COMPLEX, "arg",         0, 127, BF_ANY, TY_FLOAT,      BOPE_NONE },
  { TY_COMPLEX, "angle",       0, 127, BF_ANY, TY_FLOAT,      BOPE_NONE },
  { TY_COMPLEX, "phase",       0, 127, BF_ANY, TY_FLOAT,      BOPE_NONE },
  { TY_COMPLEX, "real",        0, 127, BF_ANY, TY_POLY,       BOPE_NONE },
  { TY_COMPLEX, "imaginary",   0, 127, BF_ANY, TY_POLY,       BOPE_NONE },
  { TY_COMPLEX, "imag",        0, 127, BF_ANY, TY_POLY,       BOPE_NONE },
  { TY_COMPLEX, "abs",         0, 127, BF_ANY, TY_POLY,       BOPE_NONE },
  { TY_COMPLEX, "magnitude",   0, 127, BF_ANY, TY_POLY,       BOPE_NONE },
  { TY_COMPLEX, "abs2",        0, 127, BF_ANY, TY_POLY,       BOPE_NONE },
  { TY_COMPLEX, "polar",       0, 127, BF_ANY, TY_POLY_ARRAY, BOPE_NONE },
  { TY_COMPLEX, "rect",        0, 127, BF_ANY, TY_POLY_ARRAY, BOPE_NONE },
  { TY_COMPLEX, "rectangular", 0, 127, BF_ANY, TY_POLY_ARRAY, BOPE_NONE },
  { TY_COMPLEX, "conjugate",   0, 127, BF_ANY, TY_COMPLEX,    BOPE_NONE },
  { TY_COMPLEX, "conj",        0, 127, BF_ANY, TY_COMPLEX,    BOPE_NONE },
  { TY_COMPLEX, "to_c",        0, 127, BF_ANY, TY_COMPLEX,    BOPE_NONE },
  { TY_COMPLEX, "-@",          0, 127, BF_ANY, TY_COMPLEX,    BOPE_NONE },
  { TY_COMPLEX, "+@",          0, 127, BF_ANY, TY_COMPLEX,    BOPE_NONE },
  { TY_COMPLEX, "+",           0, 127, BF_ANY, TY_COMPLEX,    BOPE_NONE },
  { TY_COMPLEX, "-",           0, 127, BF_ANY, TY_COMPLEX,    BOPE_NONE },
  { TY_COMPLEX, "*",           0, 127, BF_ANY, TY_COMPLEX,    BOPE_NONE },
  { TY_COMPLEX, "/",           0, 127, BF_ANY, TY_COMPLEX,    BOPE_NONE },
  { TY_COMPLEX, "quo",         0, 127, BF_ANY, TY_COMPLEX,    BOPE_NONE },
  { TY_COMPLEX, "**",          0, 127, BF_ANY, TY_COMPLEX,    BOPE_NONE },
  { TY_COMPLEX, "%",           0, 127, BF_ANY, TY_COMPLEX,    BOPE_NONE },
  { TY_COMPLEX, "modulo",      0, 127, BF_ANY, TY_COMPLEX,    BOPE_NONE },
  { TY_COMPLEX, "==",          0, 127, BF_ANY, TY_BOOL,       BOPE_NONE },
  { TY_COMPLEX, "!=",          0, 127, BF_ANY, TY_BOOL,       BOPE_NONE },
  { TY_COMPLEX, "to_s",        0, 127, BF_ANY, TY_STRING,     BOPE_NONE },
  { TY_COMPLEX, "inspect",     0, 127, BF_ANY, TY_STRING,     BOPE_NONE },
  { TY_COMPLEX, "to_i",        0, 127, BF_ANY, TY_INT,        BOPE_NONE },
  { TY_COMPLEX, "to_int",      0, 127, BF_ANY, TY_INT,        BOPE_NONE },
  { TY_COMPLEX, "denominator", 0, 127, BF_ANY, TY_INT,        BOPE_NONE },
  { TY_COMPLEX, "to_f",        0, 127, BF_ANY, TY_FLOAT,      BOPE_NONE },
  { TY_COMPLEX, "to_r",        0, 127, BF_ANY, TY_RATIONAL,   BOPE_NONE },
  { TY_COMPLEX, "numerator",   0, 127, BF_ANY, TY_COMPLEX,    BOPE_NONE },
  { TY_COMPLEX, "zero?",       0, 127, BF_ANY, TY_BOOL,       BOPE_NONE },
  { TY_COMPLEX, "real?",       0, 127, BF_ANY, TY_BOOL,       BOPE_NONE },
  { TY_COMPLEX, "integer?",    0, 127, BF_ANY, TY_BOOL,       BOPE_NONE },
  { TY_COMPLEX, "finite?",     0, 127, BF_ANY, TY_BOOL,       BOPE_NONE },
  { TY_COMPLEX, "eql?",        0, 127, BF_ANY, TY_BOOL,       BOPE_NONE },
  { TY_COMPLEX, "nonzero?",    0, 127, BF_ANY, TY_POLY,       BOPE_NONE },
  { TY_COMPLEX, "infinite?",   0, 127, BF_ANY, TY_INT,        BOPE_NONE },
  { TY_COMPLEX, "<=>",         1,   1, BF_ANY, TY_INT,        BOPE_NONE },
  { TY_COMPLEX, "rationalize", 0,   1, BF_ANY, TY_RATIONAL,   BOPE_NONE },
  { TY_COMPLEX, "fdiv",        1,   1, BF_ANY, TY_COMPLEX,    BOPE_NONE },
  { TY_COMPLEX, "coerce",      1,   1, BF_ANY, TY_POLY_ARRAY, BOPE_NONE },

  /* Rational: the result kinds that do not depend on the arguments.
     step, round/truncate/floor/ceil and the operators are typed by their
     arguments in infer_numeric_call. Rational#i holds two floats where
     CRuby keeps the exact Rational (#2706). */
  { TY_RATIONAL, "numerator",   0, 127, BF_ANY, TY_INT,        BOPE_NONE },
  { TY_RATIONAL, "denominator", 0, 127, BF_ANY, TY_INT,        BOPE_NONE },
  { TY_RATIONAL, "to_f",        0, 127, BF_ANY, TY_FLOAT,      BOPE_NONE },
  { TY_RATIONAL, "fdiv",        0, 127, BF_ANY, TY_FLOAT,      BOPE_NONE },
  { TY_RATIONAL, "to_i",        0, 127, BF_ANY, TY_INT,        BOPE_NONE },
  { TY_RATIONAL, "to_int",      0, 127, BF_ANY, TY_INT,        BOPE_NONE },
  { TY_RATIONAL, "div",         0, 127, BF_ANY, TY_INT,        BOPE_NONE },
  { TY_RATIONAL, "zero?",       0, 127, BF_ANY, TY_BOOL,       BOPE_NONE },
  { TY_RATIONAL, "positive?",   0, 127, BF_ANY, TY_BOOL,       BOPE_NONE },
  { TY_RATIONAL, "negative?",   0, 127, BF_ANY, TY_BOOL,       BOPE_NONE },
  { TY_RATIONAL, "finite?",     0, 127, BF_ANY, TY_BOOL,       BOPE_NONE },
  { TY_RATIONAL, "integer?",    0, 127, BF_ANY, TY_BOOL,       BOPE_NONE },
  { TY_RATIONAL, "real?",       0, 127, BF_ANY, TY_BOOL,       BOPE_NONE },
  { TY_RATIONAL, "infinite?",   0, 127, BF_ANY, TY_INT,        BOPE_NONE },
  { TY_RATIONAL, "imaginary",   0, 127, BF_ANY, TY_INT,        BOPE_NONE },
  { TY_RATIONAL, "imag",        0, 127, BF_ANY, TY_INT,        BOPE_NONE },
  { TY_RATIONAL, "nonzero?",    0, 127, BF_ANY, TY_POLY,       BOPE_NONE },
  { TY_RATIONAL, "arg",         0, 127, BF_ANY, TY_POLY,       BOPE_NONE },
  { TY_RATIONAL, "angle",       0, 127, BF_ANY, TY_POLY,       BOPE_NONE },
  { TY_RATIONAL, "phase",       0, 127, BF_ANY, TY_POLY,       BOPE_NONE },
  { TY_RATIONAL, "to_c",        0, 127, BF_ANY, TY_COMPLEX,    BOPE_NONE },
  { TY_RATIONAL, "i",           0,   0, BF_ANY, TY_COMPLEX,    BOPE_NONE },
  { TY_RATIONAL, "rectangular", 0, 127, BF_ANY, TY_POLY_ARRAY, BOPE_NONE },
  { TY_RATIONAL, "rect",        0, 127, BF_ANY, TY_POLY_ARRAY, BOPE_NONE },
  { TY_RATIONAL, "polar",       0, 127, BF_ANY, TY_POLY_ARRAY, BOPE_NONE },
  { TY_RATIONAL, "coerce",      1,   1, BF_ANY, TY_POLY_ARRAY, BOPE_NONE },
  { TY_RATIONAL, "to_s",        0, 127, BF_ANY, TY_STRING,     BOPE_NONE },
  { TY_RATIONAL, "inspect",     0, 127, BF_ANY, TY_STRING,     BOPE_NONE },
  { TY_RATIONAL, "to_r",        0, 127, BF_ANY, TY_RATIONAL,   BOPE_NONE },
  { TY_RATIONAL, "rationalize", 0, 127, BF_ANY, TY_RATIONAL,   BOPE_NONE },
  { TY_RATIONAL, "-@",          0, 127, BF_ANY, TY_RATIONAL,   BOPE_NONE },
  { TY_RATIONAL, "+@",          0, 127, BF_ANY, TY_RATIONAL,   BOPE_NONE },
  { TY_RATIONAL, "abs",         0, 127, BF_ANY, TY_RATIONAL,   BOPE_NONE },
  { TY_RATIONAL, "real",        0, 127, BF_ANY, TY_RATIONAL,   BOPE_NONE },
  { TY_RATIONAL, "conjugate",   0, 127, BF_ANY, TY_RATIONAL,   BOPE_NONE },
  { TY_RATIONAL, "conj",        0, 127, BF_ANY, TY_RATIONAL,   BOPE_NONE },
  { TY_RATIONAL, "abs2",        0, 127, BF_ANY, TY_RATIONAL,   BOPE_NONE },
  { TY_RATIONAL, "magnitude",   0, 127, BF_ANY, TY_RATIONAL,   BOPE_NONE },

  /* String range ("a".."e"): the endpoints answer natively (with a count,
     the materialized prefix); every traversal rides the element array
     (#3064). step(n) / %(n) is an Enumerator over every nth member (#3671).
     #size counts INTEGER elements, so it is nil here, as in CRuby. */
  { TY_STR_RANGE, "begin",        0,   0, BF_ANY,      TY_STRING,      BOPE_NONE },
  { TY_STR_RANGE, "end",          0,   0, BF_ANY,      TY_STRING,      BOPE_NONE },
  { TY_STR_RANGE, "min",          0,   0, BF_ANY,      TY_STRING,      BOPE_NONE },
  { TY_STR_RANGE, "max",          0,   0, BF_ANY,      TY_STRING,      BOPE_NONE },
  { TY_STR_RANGE, "to_s",         0,   0, BF_ANY,      TY_STRING,      BOPE_NONE },
  { TY_STR_RANGE, "inspect",      0,   0, BF_ANY,      TY_STRING,      BOPE_NONE },
  { TY_STR_RANGE, "first",        0,   0, BF_ANY,      TY_STRING,      BOPE_NONE },
  { TY_STR_RANGE, "last",         0,   0, BF_ANY,      TY_STRING,      BOPE_NONE },
  { TY_STR_RANGE, "begin",        1, 127, BF_ANY,      TY_STR_ARRAY,   BOPE_NONE },
  { TY_STR_RANGE, "end",          1, 127, BF_ANY,      TY_STR_ARRAY,   BOPE_NONE },
  { TY_STR_RANGE, "min",          1, 127, BF_ANY,      TY_STR_ARRAY,   BOPE_NONE },
  { TY_STR_RANGE, "max",          1, 127, BF_ANY,      TY_STR_ARRAY,   BOPE_NONE },
  { TY_STR_RANGE, "to_s",         1, 127, BF_ANY,      TY_STR_ARRAY,   BOPE_NONE },
  { TY_STR_RANGE, "inspect",      1, 127, BF_ANY,      TY_STR_ARRAY,   BOPE_NONE },
  { TY_STR_RANGE, "first",        1, 127, BF_ANY,      TY_STR_ARRAY,   BOPE_NONE },
  { TY_STR_RANGE, "last",         1, 127, BF_ANY,      TY_STR_ARRAY,   BOPE_NONE },
  { TY_STR_RANGE, "cover?",       0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_STR_RANGE, "include?",     0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_STR_RANGE, "member?",      0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_STR_RANGE, "===",          0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_STR_RANGE, "==",           0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_STR_RANGE, "!=",           0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_STR_RANGE, "eql?",         0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_STR_RANGE, "exclude_end?", 0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_STR_RANGE, "frozen?",      0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_STR_RANGE, "nil?",         0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_STR_RANGE, "is_a?",        0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_STR_RANGE, "kind_of?",     0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_STR_RANGE, "instance_of?", 0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_STR_RANGE, "equal?",       0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_STR_RANGE, "respond_to?",  0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_STR_RANGE, "step",         1,   1, BF_NONE,     TY_ENUMERATOR,  BOPE_NONE },
  { TY_STR_RANGE, "%",            1,   1, BF_NONE,     TY_ENUMERATOR,  BOPE_NONE },
  { TY_STR_RANGE, "class",        0, 127, BF_ANY,      TY_CLASS,       BOPE_NONE },
  { TY_STR_RANGE, "hash",         0, 127, BF_ANY,      TY_INT,         BOPE_NONE },
  { TY_STR_RANGE, "size",         0,   0, BF_ANY,      TY_NIL,         BOPE_NONE },
  { TY_STR_RANGE, "to_a",         0,   0, BF_ANY,      TY_STR_ARRAY,   BOPE_NONE },
  { TY_STR_RANGE, "entries",      0,   0, BF_ANY,      TY_STR_ARRAY,   BOPE_NONE },
  { TY_STR_RANGE, "freeze",       0, 127, BF_ANY,      TY_STR_RANGE,   BOPE_NONE },
  { TY_STR_RANGE, "itself",       0, 127, BF_ANY,      TY_STR_RANGE,   BOPE_NONE },
  { TY_STR_RANGE, "dup",          0, 127, BF_ANY,      TY_STR_RANGE,   BOPE_NONE },
  { TY_STR_RANGE, "clone",        0, 127, BF_ANY,      TY_STR_RANGE,   BOPE_NONE },

  /* Float range (1.0..3.0): not iterable. minmax is the endpoints (#3690).
     The iterators raise "can't iterate from Float" at run time and type
     poly, which keeps the raise's boxed-nil slot valid and lets respond_to?
     report them present, as CRuby does. The endpoint readers and #size
     read the literal and stay in infer_range_call. */
  { TY_FLOAT_RANGE, "cover?",           0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_FLOAT_RANGE, "include?",         0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_FLOAT_RANGE, "member?",          0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_FLOAT_RANGE, "===",              0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_FLOAT_RANGE, "==",               0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_FLOAT_RANGE, "!=",               0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_FLOAT_RANGE, "eql?",             0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_FLOAT_RANGE, "exclude_end?",     0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_FLOAT_RANGE, "frozen?",          0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_FLOAT_RANGE, "nil?",             0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_FLOAT_RANGE, "is_a?",            0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_FLOAT_RANGE, "kind_of?",         0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_FLOAT_RANGE, "instance_of?",     0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_FLOAT_RANGE, "equal?",           0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_FLOAT_RANGE, "respond_to?",      0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_FLOAT_RANGE, "to_s",             0, 127, BF_ANY,      TY_STRING,      BOPE_NONE },
  { TY_FLOAT_RANGE, "inspect",          0, 127, BF_ANY,      TY_STRING,      BOPE_NONE },
  { TY_FLOAT_RANGE, "minmax",           0,   0, BF_ANY,      TY_FLOAT_ARRAY, BOPE_NONE },
  { TY_FLOAT_RANGE, "step",             0, 127, BF_ANY,      TY_FLOAT_ARRAY, BOPE_NONE },
  { TY_FLOAT_RANGE, "bsearch",          0, 127, BF_REQUIRED, TY_FLOAT,       BOPE_NONE },
  { TY_FLOAT_RANGE, "class",            0, 127, BF_ANY,      TY_CLASS,       BOPE_NONE },
  { TY_FLOAT_RANGE, "freeze",           0, 127, BF_ANY,      TY_FLOAT_RANGE, BOPE_NONE },
  { TY_FLOAT_RANGE, "itself",           0, 127, BF_ANY,      TY_FLOAT_RANGE, BOPE_NONE },
  { TY_FLOAT_RANGE, "dup",              0, 127, BF_ANY,      TY_FLOAT_RANGE, BOPE_NONE },
  { TY_FLOAT_RANGE, "clone",            0, 127, BF_ANY,      TY_FLOAT_RANGE, BOPE_NONE },
  { TY_FLOAT_RANGE, "each",             0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "map",              0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "collect",          0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "select",           0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "filter",           0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "reject",           0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "to_a",             0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "to_h",             0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "entries",          0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "find",             0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "detect",           0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "find_index",       0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "count",            0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "sum",              0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "sort",             0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "sort_by",          0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "min_by",           0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "max_by",           0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "reduce",           0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "inject",           0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "each_with_index",  0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "flat_map",         0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "collect_concat",   0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "any?",             0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "all?",             0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "none?",            0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "one?",             0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "take",             0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "drop",             0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "take_while",       0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "drop_while",       0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "filter_map",       0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "partition",        0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "group_by",         0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "each_with_object", 0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "tally",            0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "find_all",         0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "zip",              0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "grep",             0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "grep_v",           0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "uniq",             0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "reverse",          0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "minmax",           1, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "join",             0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "index",            0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "size",             0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "lazy",             0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "each_cons",        0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "each_slice",       0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "chunk",            0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "chunk_while",      0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_FLOAT_RANGE, "cycle",            0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },

  /* Enumerator. The block forms run over the materialized pairs or the
     lazy #next driver. Enumerator#+ and with_index with a block are typed
     by their operand and receiver in infer_call_inner. */
  { TY_ENUMERATOR, "next",            0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_ENUMERATOR, "peek",            0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },
  { TY_ENUMERATOR, "find",            0, 127, BF_REQUIRED, TY_POLY,        BOPE_NONE },  /* lazily via #next, nil on no match (#3236) */
  { TY_ENUMERATOR, "detect",          0, 127, BF_REQUIRED, TY_POLY,        BOPE_NONE },  /* lazily via #next, nil on no match (#3236) */
  { TY_ENUMERATOR, "take_while",      0, 127, BF_REQUIRED, TY_POLY_ARRAY,  BOPE_NONE },  /* the same lazy driver (#3590) */
  { TY_ENUMERATOR, "include?",        1,   1, BF_NONE,     TY_BOOL,        BOPE_NONE },
  { TY_ENUMERATOR, "member?",         1,   1, BF_NONE,     TY_BOOL,        BOPE_NONE },
  { TY_ENUMERATOR, "find_index",      1,   1, BF_NONE,     TY_INT,         BOPE_NONE },
  { TY_ENUMERATOR, "next_values",     0, 127, BF_ANY,      TY_POLY_ARRAY,  BOPE_NONE },  /* #2482 */
  { TY_ENUMERATOR, "peek_values",     0, 127, BF_ANY,      TY_POLY_ARRAY,  BOPE_NONE },  /* #2482 */
  { TY_ENUMERATOR, "rewind",          0, 127, BF_ANY,      TY_ENUMERATOR,  BOPE_NONE },
  { TY_ENUMERATOR, "frozen?",         0, 127, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_ENUMERATOR, "equal?",          1,   1, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_ENUMERATOR, "eql?",            1,   1, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_ENUMERATOR, "==",              1,   1, BF_ANY,      TY_BOOL,        BOPE_NONE },
  { TY_ENUMERATOR, "freeze",          0, 127, BF_ANY,      TY_ENUMERATOR,  BOPE_NONE },
  { TY_ENUMERATOR, "itself",          0, 127, BF_ANY,      TY_ENUMERATOR,  BOPE_NONE },
  { TY_ENUMERATOR, "feed",            1,   1, BF_ANY,      TY_NIL,         BOPE_NONE },
  { TY_ENUMERATOR, "with_index",      0,   1, BF_NONE,     TY_ENUMERATOR,  BOPE_NONE },  /* over [element, index] pairs */
  { TY_ENUMERATOR, "each_with_index", 0,   0, BF_NONE,     TY_ENUMERATOR,  BOPE_NONE },  /* #2487 */
  { TY_ENUMERATOR, "each_index",      0,   0, BF_NONE,     TY_ENUMERATOR,  BOPE_NONE },  /* #2487 */
  { TY_ENUMERATOR, "size",            0, 127, BF_ANY,      TY_POLY,        BOPE_NONE },  /* nil, an Integer or a stored size */
  { TY_ENUMERATOR, "take",            1,   1, BF_ANY,      TY_POLY_ARRAY,  BOPE_NONE },
  { TY_ENUMERATOR, "first",           1,   1, BF_ANY,      TY_POLY_ARRAY,  BOPE_NONE },
  { TY_ENUMERATOR, "drop",            1,   1, BF_NONE,     TY_POLY_ARRAY,  BOPE_NONE },
  { TY_ENUMERATOR, "reject",          0,   0, BF_REQUIRED, TY_POLY_ARRAY,  BOPE_NONE },
  { TY_ENUMERATOR, "select",          0,   0, BF_REQUIRED, TY_POLY_ARRAY,  BOPE_NONE },
  { TY_ENUMERATOR, "filter",          0,   0, BF_REQUIRED, TY_POLY_ARRAY,  BOPE_NONE },
  { TY_ENUMERATOR, "map",             0,   0, BF_REQUIRED, TY_POLY_ARRAY,  BOPE_NONE },
  { TY_ENUMERATOR, "collect",         0,   0, BF_REQUIRED, TY_POLY_ARRAY,  BOPE_NONE },
  { TY_ENUMERATOR, "sort_by",         0,   0, BF_REQUIRED, TY_POLY_ARRAY,  BOPE_NONE },
  { TY_ENUMERATOR, "sum",             0,   0, BF_REQUIRED, TY_POLY,        BOPE_NONE },
  { TY_ENUMERATOR, "to_a",            0,   0, BF_ANY,      TY_POLY_ARRAY,  BOPE_NONE },
  { TY_ENUMERATOR, "entries",         0,   0, BF_ANY,      TY_POLY_ARRAY,  BOPE_NONE },
  { TY_ENUMERATOR, "inspect",         0,   0, BF_ANY,      TY_STRING,      BOPE_NONE },
  { TY_ENUMERATOR, "to_s",            0,   0, BF_ANY,      TY_STRING,      BOPE_NONE },

  /* Time: the result kinds of the calls whose arms render more than the
     receiver (emitted in emit_value_recv_call). Time - Time and Time - poly
     are typed by the operand before the lookup; iso8601, httpdate and
     rfc2822 depend on the time feature, <=> on the operand. */
  { TY_TIME, "utc",        0, 127, BF_ANY, TY_TIME,       BOPE_NONE },
  { TY_TIME, "gmtime",     0, 127, BF_ANY, TY_TIME,       BOPE_NONE },
  { TY_TIME, "getutc",     0, 127, BF_ANY, TY_TIME,       BOPE_NONE },
  { TY_TIME, "localtime",  0, 127, BF_ANY, TY_TIME,       BOPE_NONE },
  { TY_TIME, "getlocal",   0, 127, BF_ANY, TY_TIME,       BOPE_NONE },
  { TY_TIME, "+",          0, 127, BF_ANY, TY_TIME,       BOPE_NONE },
  { TY_TIME, "-",          0, 127, BF_ANY, TY_TIME,       BOPE_NONE },
  { TY_TIME, "clamp",      2,   2, BF_ANY, TY_TIME,       BOPE_NONE },  /* self or a bound */
  { TY_TIME, "to_a",       0,   0, BF_ANY, TY_POLY_ARRAY, BOPE_NONE },
  { TY_TIME, "to_r",       0,   0, BF_ANY, TY_RATIONAL,   BOPE_NONE },
  { TY_TIME, "floor",      0,   1, BF_ANY, TY_TIME,       BOPE_NONE },
  { TY_TIME, "ceil",       0,   1, BF_ANY, TY_TIME,       BOPE_NONE },
  { TY_TIME, "round",      0,   1, BF_ANY, TY_TIME,       BOPE_NONE },
  { TY_TIME, "xmlschema",  0, 127, BF_ANY, TY_STRING,     BOPE_NONE },  /* with or without fraction digits (#3094) */
  { TY_TIME, "deconstruct_keys", 1,   1, BF_ANY, TY_POLY,       BOPE_NONE },  /* a boxed Symbol => Integer hash */
  { TY_TIME, "strftime",   0, 127, BF_ANY, TY_STRING,     BOPE_NONE },
  { TY_TIME, "to_f",       0, 127, BF_ANY, TY_FLOAT,      BOPE_NONE },
  { TY_TIME, "subsec",     0, 127, BF_ANY, TY_POLY,       BOPE_NONE },  /* Integer 0 for a whole second, else a Rational */
  { TY_TIME, "<",          0, 127, BF_ANY, TY_BOOL,       BOPE_NONE },
  { TY_TIME, ">",          0, 127, BF_ANY, TY_BOOL,       BOPE_NONE },
  { TY_TIME, "<=",         0, 127, BF_ANY, TY_BOOL,       BOPE_NONE },
  { TY_TIME, ">=",         0, 127, BF_ANY, TY_BOOL,       BOPE_NONE },
  { TY_TIME, "==",         0, 127, BF_ANY, TY_BOOL,       BOPE_NONE },
  { TY_TIME, "!=",         0, 127, BF_ANY, TY_BOOL,       BOPE_NONE },
  /* The concurrency handles: Fiber, Thread, Queue (SizedQueue too: one
     kind, told apart at run time by its bound), Mutex and
     ConditionVariable. Inference typed most names for any arity where
     codegen emits only some, so a name often has a codegen row for its
     arity and a wider BOPE_NONE row after it that only types the call. */

  /* Fiber. #inspect / #to_s are emitted here but were never typed by the
     Fiber rules, so they leave inference to the rules after them. */
  { TY_FIBER, "resume",        0, BOP_ARGC_ANY, BF_ANY, TY_POLY,    BOPE_FIBER_RESUME },
  { TY_FIBER, "transfer",      0, BOP_ARGC_ANY, BF_ANY, TY_POLY,    BOPE_FIBER_TRANSFER },
  { TY_FIBER, "raise",         0, BOP_ARGC_ANY, BF_ANY, TY_POLY,    BOPE_FIBER_RAISE },
  /* the fiber's own storage by a literal key: what a `Fiber.attr_accessor`
     reader and writer (desugar_handle_attr_accessor) read and write on self */
  { TY_FIBER, "__storage_get", 1, 1, BF_ANY, TY_POLY, BOPE_TEMPLATE, "sp_Fiber_attr_get($r, $e0)", TY_SYMBOL },
  { TY_FIBER, "__storage_get", 0, BOP_ARGC_ANY, BF_ANY, TY_POLY,    BOPE_NONE },
  { TY_FIBER, "__storage_set", 2, 2, BF_ANY, TY_POLY, BOPE_TEMPLATE,
    "({ sp_RbVal _t$t = $b1; SP_GC_ROOT_RBVAL(_t$t); sp_Fiber_attr_set($r, $e0, _t$t); _t$t; })", TY_SYMBOL },
  { TY_FIBER, "__storage_set", 0, BOP_ARGC_ANY, BF_ANY, TY_POLY,    BOPE_NONE },
  { TY_FIBER, "alive?",        0, BOP_ARGC_ANY, BF_ANY, TY_BOOL,    BOPE_TEMPLATE, "sp_Fiber_alive($r)" },
  /* Fiber#value: resume until the fiber finishes, answering the last value */
  { TY_FIBER, "value",         0, BOP_ARGC_ANY, BF_ANY, TY_POLY,    BOPE_TEMPLATE, "sp_Fiber_resume($r, sp_box_nil())" },
  { TY_FIBER, "kill",          0, 0,            BF_ANY, TY_FIBER,   BOPE_TEMPLATE, "sp_Fiber_kill($r)" },
  { TY_FIBER, "kill",          0, BOP_ARGC_ANY, BF_ANY, TY_FIBER,   BOPE_NONE },   /* the receiver */
  /* the running fiber's storage as a Hash copy (or nil), or replaced by one */
  { TY_FIBER, "storage",       0, 0,            BF_ANY, TY_POLY,    BOPE_TEMPLATE, "sp_Fiber_storage_hash($r)" },
  { TY_FIBER, "storage=",      1, 1, BF_ANY, TY_POLY, BOPE_TEMPLATE,
    "({ sp_RbVal _t$t = $b0; SP_GC_ROOT_RBVAL(_t$t); sp_Fiber_storage_assign($r, _t$t); _t$t; })" },
  { TY_FIBER, "blocking?",     0, 0,            BF_ANY, TY_BOOL,    BOPE_TEMPLATE, "sp_Fiber_blocking_p($r)" },
  { TY_FIBER, "inspect",       0, 0,            BF_ANY, TY_UNKNOWN, BOPE_TEMPLATE, "sp_Fiber_inspect($r)" },
  { TY_FIBER, "to_s",          0, 0,            BF_ANY, TY_UNKNOWN, BOPE_TEMPLATE, "sp_Fiber_inspect($r)" },

  /* Thread (a green thread on the scheduler). The universal queries come
     first for each handle kind (#3124). NULL encodes nil, as it does for an
     exception: a slot holding a handle may hold nil, so nil? is not a flat
     false (#3483); frozen? is emitted by emit_call_recv's arm, which reads
     the GC header's bit. */
  { TY_THREAD, "class",   0, 0, BF_ANY, TY_CLASS,  BOPE_NONE },
  { TY_THREAD, "frozen?", 0, 0, BF_ANY, TY_BOOL,   BOPE_NONE },
  { TY_THREAD, "nil?",    0, 0, BF_ANY, TY_BOOL,   BOPE_TEMPLATE, "(($r) == NULL)" },
  { TY_THREAD, "itself",  0, 0, BF_ANY, TY_THREAD, BOPE_TEMPLATE, "$r" },
  { TY_THREAD, "inspect", 0, 0, BF_ANY, TY_STRING, BOPE_TEMPLATE, "sp_Thread_inspect($r)" },
  { TY_THREAD, "to_s",    0, 0, BF_ANY, TY_STRING, BOPE_TEMPLATE, "sp_Thread_inspect($r)" },
  { TY_THREAD, "value",   0, 0,            BF_ANY, TY_POLY,   BOPE_TEMPLATE, "sp_Thread_value($r)" },
  { TY_THREAD, "value",   0, BOP_ARGC_ANY, BF_ANY, TY_POLY,   BOPE_NONE },
  /* join, kill, exit, terminate, raise, wakeup and run answer the receiver.
     join(limit) waits at most limit seconds, nil on a timeout; the limit
     goes through emit_float_expr, so a poly value is unboxed by
     sp_poly_to_f (CRuby's "can't convert X into Float") */
  { TY_THREAD, "join",      0, 0,            BF_ANY, TY_THREAD, BOPE_TEMPLATE, "sp_Thread_join($r)" },
  { TY_THREAD, "join",      1, 1,            BF_ANY, TY_THREAD, BOPE_TEMPLATE, "sp_Thread_join_timeout($r, $f0)" },
  { TY_THREAD, "join",      0, BOP_ARGC_ANY, BF_ANY, TY_THREAD, BOPE_NONE },
  { TY_THREAD, "kill",      0, 0,            BF_ANY, TY_THREAD, BOPE_TEMPLATE, "sp_Thread_kill($r)" },
  { TY_THREAD, "kill",      0, BOP_ARGC_ANY, BF_ANY, TY_THREAD, BOPE_NONE },
  { TY_THREAD, "exit",      0, 0,            BF_ANY, TY_THREAD, BOPE_TEMPLATE, "sp_Thread_kill($r)" },
  { TY_THREAD, "exit",      0, BOP_ARGC_ANY, BF_ANY, TY_THREAD, BOPE_NONE },
  { TY_THREAD, "terminate", 0, 0,            BF_ANY, TY_THREAD, BOPE_TEMPLATE, "sp_Thread_kill($r)" },
  { TY_THREAD, "terminate", 0, BOP_ARGC_ANY, BF_ANY, TY_THREAD, BOPE_NONE },
  { TY_THREAD, "raise",     0, BOP_ARGC_ANY, BF_ANY, TY_THREAD, BOPE_THREAD_RAISE },
  { TY_THREAD, "wakeup",    0, 0,            BF_ANY, TY_THREAD, BOPE_TEMPLATE, "sp_Thread_wakeup($r)" },
  { TY_THREAD, "wakeup",    0, BOP_ARGC_ANY, BF_ANY, TY_THREAD, BOPE_NONE },
  { TY_THREAD, "run",       0, 0,            BF_ANY, TY_THREAD, BOPE_TEMPLATE, "sp_Thread_run($r)" },
  { TY_THREAD, "run",       0, BOP_ARGC_ANY, BF_ANY, TY_THREAD, BOPE_NONE },
  { TY_THREAD, "alive?",    0, 0,            BF_ANY, TY_BOOL,   BOPE_TEMPLATE, "sp_Thread_alive($r)" },
  { TY_THREAD, "alive?",    0, BOP_ARGC_ANY, BF_ANY, TY_BOOL,   BOPE_NONE },
  { TY_THREAD, "stop?",     0, 0,            BF_ANY, TY_BOOL,   BOPE_TEMPLATE, "sp_Thread_stop_p($r)" },
  { TY_THREAD, "stop?",     0, BOP_ARGC_ANY, BF_ANY, TY_BOOL,   BOPE_NONE },
  { TY_THREAD, "report_on_exception",  0, 0,            BF_ANY, TY_BOOL, BOPE_TEMPLATE, "sp_Thread_get_report($r)" },
  { TY_THREAD, "report_on_exception",  0, BOP_ARGC_ANY, BF_ANY, TY_BOOL, BOPE_NONE },
  { TY_THREAD, "report_on_exception=", 1, 1,            BF_ANY, TY_BOOL, BOPE_THREAD_SET_REPORT },
  { TY_THREAD, "report_on_exception=", 0, BOP_ARGC_ANY, BF_ANY, TY_BOOL, BOPE_NONE },
  { TY_THREAD, "status",    0, 0,            BF_ANY, TY_POLY,   BOPE_TEMPLATE, "sp_Thread_status($r)" },
  { TY_THREAD, "status",    0, BOP_ARGC_ANY, BF_ANY, TY_POLY,   BOPE_NONE },
  { TY_THREAD, "name",      0, 0,            BF_ANY, TY_POLY,   BOPE_TEMPLATE, "sp_Thread_get_name($r)" },
  { TY_THREAD, "name",      0, BOP_ARGC_ANY, BF_ANY, TY_POLY,   BOPE_NONE },
  { TY_THREAD, "name=",     1, 1,            BF_ANY, TY_POLY,   BOPE_TEMPLATE, "sp_Thread_set_name($r, $b0)" },
  { TY_THREAD, "name=",     0, BOP_ARGC_ANY, BF_ANY, TY_POLY,   BOPE_NONE },
  { TY_THREAD, "equal?",    1, 1, BF_ANY, TY_BOOL, BOPE_TEMPLATE, "((void *)($r) == (void *)($e0))", TY_THREAD },
  { TY_THREAD, "equal?",    0, BOP_ARGC_ANY, BF_ANY, TY_BOOL,   BOPE_NONE },
  /* thread-local storage: t[:key] / t[:key] = v / t.key?(:key) by a symbol
     key directly, any other key through sp_thread_local_key.
     thread_variable_get / _set / ? are the thread-local spellings of the
     same store (`[]` is fiber-local in CRuby; this runtime keeps one table
     per thread for both) -- activesupport's IsolatedExecutionState reads it */
  { TY_THREAD, "[]",   1, 1, BF_ANY, TY_POLY, BOPE_TEMPLATE, "sp_Thread_tls_get($r, $e0)", TY_SYMBOL },
  { TY_THREAD, "[]",   1, 1, BF_ANY, TY_POLY, BOPE_THREAD_TLS },
  { TY_THREAD, "[]",   0, BOP_ARGC_ANY, BF_ANY, TY_POLY, BOPE_NONE },
  { TY_THREAD, "[]=",  2, 2, BF_ANY, TY_POLY, BOPE_TEMPLATE, "sp_Thread_tls_set($r, $e0, $b1)", TY_SYMBOL },
  { TY_THREAD, "[]=",  2, 2, BF_ANY, TY_POLY, BOPE_THREAD_TLS },
  { TY_THREAD, "[]=",  0, BOP_ARGC_ANY, BF_ANY, TY_POLY, BOPE_NONE },
  { TY_THREAD, "key?", 1, 1, BF_ANY, TY_BOOL, BOPE_TEMPLATE, "sp_Thread_tls_key($r, $e0)", TY_SYMBOL },
  { TY_THREAD, "key?", 1, 1, BF_ANY, TY_BOOL, BOPE_THREAD_TLS },
  { TY_THREAD, "key?", 0, BOP_ARGC_ANY, BF_ANY, TY_BOOL, BOPE_NONE },
  { TY_THREAD, "thread_variable_get", 1, 1,            BF_ANY, TY_POLY, BOPE_THREAD_TLS },
  { TY_THREAD, "thread_variable_get", 0, BOP_ARGC_ANY, BF_ANY, TY_POLY, BOPE_NONE },
  { TY_THREAD, "thread_variable_set", 2, 2,            BF_ANY, TY_POLY, BOPE_THREAD_TLS },
  { TY_THREAD, "thread_variable_set", 0, BOP_ARGC_ANY, BF_ANY, TY_POLY, BOPE_NONE },
  { TY_THREAD, "thread_variable?",    1, 1,            BF_ANY, TY_BOOL, BOPE_THREAD_TLS },
  { TY_THREAD, "thread_variable?",    0, BOP_ARGC_ANY, BF_ANY, TY_BOOL, BOPE_NONE },
  { TY_THREAD, "keys", 0, 0, BF_ANY, TY_POLY_ARRAY, BOPE_TEMPLATE, "sp_Thread_tls_keys($r)" },

  /* Queue (a thread-safe FIFO on the scheduler). push and pop take a
     non_block flag and a timeout: keyword, so their arity counts the
     keyword hash; the emitter declines a form it does not take. push,
     close and clear answer the receiver. */
  { TY_QUEUE, "class",   0, 0, BF_ANY, TY_CLASS, BOPE_NONE },
  { TY_QUEUE, "frozen?", 0, 0, BF_ANY, TY_BOOL,  BOPE_NONE },
  { TY_QUEUE, "nil?",    0, 0, BF_ANY, TY_BOOL,  BOPE_TEMPLATE, "(($r) == NULL)" },
  { TY_QUEUE, "itself",  0, 0, BF_ANY, TY_QUEUE, BOPE_TEMPLATE, "$r" },
  { TY_QUEUE, "pop",     0, 2,            BF_ANY, TY_POLY,  BOPE_QUEUE_POP },
  { TY_QUEUE, "pop",     0, BOP_ARGC_ANY, BF_ANY, TY_POLY,  BOPE_NONE },
  { TY_QUEUE, "shift",   0, 2,            BF_ANY, TY_POLY,  BOPE_QUEUE_POP },
  { TY_QUEUE, "shift",   0, BOP_ARGC_ANY, BF_ANY, TY_POLY,  BOPE_NONE },
  { TY_QUEUE, "deq",     0, 2,            BF_ANY, TY_POLY,  BOPE_QUEUE_POP },
  { TY_QUEUE, "deq",     0, BOP_ARGC_ANY, BF_ANY, TY_POLY,  BOPE_NONE },
  { TY_QUEUE, "push",    1, 3,            BF_ANY, TY_QUEUE, BOPE_QUEUE_PUSH },
  { TY_QUEUE, "push",    0, BOP_ARGC_ANY, BF_ANY, TY_QUEUE, BOPE_NONE },
  { TY_QUEUE, "<<",      1, 3,            BF_ANY, TY_QUEUE, BOPE_QUEUE_PUSH },
  { TY_QUEUE, "<<",      0, BOP_ARGC_ANY, BF_ANY, TY_QUEUE, BOPE_NONE },
  { TY_QUEUE, "enq",     1, 3,            BF_ANY, TY_QUEUE, BOPE_QUEUE_PUSH },
  { TY_QUEUE, "enq",     0, BOP_ARGC_ANY, BF_ANY, TY_QUEUE, BOPE_NONE },
  { TY_QUEUE, "close",   0, 0,            BF_ANY, TY_QUEUE, BOPE_TEMPLATE, "({ sp_queue *_t$t = $r; sp_Queue_close(_t$t); _t$t; })" },
  { TY_QUEUE, "close",   0, BOP_ARGC_ANY, BF_ANY, TY_QUEUE, BOPE_NONE },
  { TY_QUEUE, "clear",   0, 0,            BF_ANY, TY_QUEUE, BOPE_TEMPLATE, "({ sp_queue *_t$t = $r; sp_Queue_clear(_t$t); _t$t; })" },
  { TY_QUEUE, "clear",   0, BOP_ARGC_ANY, BF_ANY, TY_QUEUE, BOPE_NONE },
  { TY_QUEUE, "size",    0, 0,            BF_ANY, TY_INT,   BOPE_TEMPLATE, "sp_Queue_size($r)" },
  { TY_QUEUE, "size",    0, BOP_ARGC_ANY, BF_ANY, TY_INT,   BOPE_NONE },
  { TY_QUEUE, "length",  0, 0,            BF_ANY, TY_INT,   BOPE_TEMPLATE, "sp_Queue_size($r)" },
  { TY_QUEUE, "length",  0, BOP_ARGC_ANY, BF_ANY, TY_INT,   BOPE_NONE },
  { TY_QUEUE, "max",     0, 0,            BF_ANY, TY_INT,   BOPE_TEMPLATE, "sp_Queue_max($r)" },
  { TY_QUEUE, "max",     0, BOP_ARGC_ANY, BF_ANY, TY_INT,   BOPE_NONE },
  { TY_QUEUE, "num_waiting", 0, 0,            BF_ANY, TY_INT, BOPE_TEMPLATE, "sp_Queue_num_waiting($r)" },
  { TY_QUEUE, "num_waiting", 0, BOP_ARGC_ANY, BF_ANY, TY_INT, BOPE_NONE },
  { TY_QUEUE, "empty?",  0, 0,            BF_ANY, TY_BOOL,  BOPE_TEMPLATE, "sp_Queue_empty($r)" },
  { TY_QUEUE, "empty?",  0, BOP_ARGC_ANY, BF_ANY, TY_BOOL,  BOPE_NONE },
  { TY_QUEUE, "closed?", 0, 0,            BF_ANY, TY_BOOL,  BOPE_TEMPLATE, "sp_Queue_closed($r)" },
  { TY_QUEUE, "closed?", 0, BOP_ARGC_ANY, BF_ANY, TY_BOOL,  BOPE_NONE },

  /* Mutex. lock and unlock answer the receiver; synchronize, the block's
     value, is emitted by the generic block handler; sleep answers nil on a
     timeout, else the seconds slept. */
  { TY_MUTEX, "class",       0, 0, BF_ANY, TY_CLASS, BOPE_NONE },
  { TY_MUTEX, "frozen?",     0, 0, BF_ANY, TY_BOOL,  BOPE_NONE },
  { TY_MUTEX, "nil?",        0, 0, BF_ANY, TY_BOOL,  BOPE_TEMPLATE, "(($r) == NULL)" },
  { TY_MUTEX, "itself",      0, 0, BF_ANY, TY_MUTEX, BOPE_TEMPLATE, "$r" },
  { TY_MUTEX, "lock",        0, 0,            BF_ANY, TY_MUTEX, BOPE_TEMPLATE, "({ sp_mutex *_t$t = $r; sp_Mutex_lock(_t$t); _t$t; })" },
  { TY_MUTEX, "lock",        0, BOP_ARGC_ANY, BF_ANY, TY_MUTEX, BOPE_NONE },
  { TY_MUTEX, "unlock",      0, 0,            BF_ANY, TY_MUTEX, BOPE_TEMPLATE, "({ sp_mutex *_t$t = $r; sp_Mutex_unlock(_t$t); _t$t; })" },
  { TY_MUTEX, "unlock",      0, BOP_ARGC_ANY, BF_ANY, TY_MUTEX, BOPE_NONE },
  { TY_MUTEX, "try_lock",    0, 0,            BF_ANY, TY_BOOL,  BOPE_TEMPLATE, "sp_Mutex_try_lock($r)" },
  { TY_MUTEX, "try_lock",    0, BOP_ARGC_ANY, BF_ANY, TY_BOOL,  BOPE_NONE },
  { TY_MUTEX, "locked?",     0, 0,            BF_ANY, TY_BOOL,  BOPE_TEMPLATE, "sp_Mutex_locked($r)" },
  { TY_MUTEX, "locked?",     0, BOP_ARGC_ANY, BF_ANY, TY_BOOL,  BOPE_NONE },
  { TY_MUTEX, "owned?",      0, 0,            BF_ANY, TY_BOOL,  BOPE_TEMPLATE, "sp_Mutex_owned($r)" },
  { TY_MUTEX, "owned?",      0, BOP_ARGC_ANY, BF_ANY, TY_BOOL,  BOPE_NONE },
  { TY_MUTEX, "synchronize", 0, BOP_ARGC_ANY, BF_ANY, TY_POLY,  BOPE_NONE },
  { TY_MUTEX, "sleep",       0, 1,            BF_ANY, TY_POLY,  BOPE_MUTEX_SLEEP },
  { TY_MUTEX, "sleep",       0, BOP_ARGC_ANY, BF_ANY, TY_POLY,  BOPE_NONE },

  /* ConditionVariable. #wait answers nil (timed out) or the Integer
     seconds slept, as CRuby; signal and broadcast answer the receiver. */
  { TY_CONDVAR, "class",     0, 0, BF_ANY, TY_CLASS,   BOPE_NONE },
  { TY_CONDVAR, "frozen?",   0, 0, BF_ANY, TY_BOOL,    BOPE_NONE },
  { TY_CONDVAR, "nil?",      0, 0, BF_ANY, TY_BOOL,    BOPE_TEMPLATE, "(($r) == NULL)" },
  { TY_CONDVAR, "itself",    0, 0, BF_ANY, TY_CONDVAR, BOPE_TEMPLATE, "$r" },
  { TY_CONDVAR, "wait",      1, 2,            BF_ANY, TY_POLY,    BOPE_CONDVAR_WAIT },
  { TY_CONDVAR, "wait",      0, BOP_ARGC_ANY, BF_ANY, TY_POLY,    BOPE_NONE },
  { TY_CONDVAR, "signal",    0, 0,            BF_ANY, TY_CONDVAR, BOPE_TEMPLATE, "({ sp_condvar *_t$t = $r; sp_CondVar_signal(_t$t); _t$t; })" },
  { TY_CONDVAR, "signal",    0, BOP_ARGC_ANY, BF_ANY, TY_CONDVAR, BOPE_NONE },
  { TY_CONDVAR, "broadcast", 0, 0,            BF_ANY, TY_CONDVAR, BOPE_TEMPLATE, "({ sp_condvar *_t$t = $r; sp_CondVar_broadcast(_t$t); _t$t; })" },
  { TY_CONDVAR, "broadcast", 0, BOP_ARGC_ANY, BF_ANY, TY_CONDVAR, BOPE_NONE },
};
#define BOP_NROWS ((int)(sizeof bop_rows / sizeof bop_rows[0]))

/* Row indices sorted by (receiver kind, name), built on first use. */
static int bop_index[BOP_NROWS];
static int bop_indexed;

static int bop_cmp_key(TyKind rt, const char *name, const BuiltinOp *r) {
  if (rt != r->recv) return rt < r->recv ? -1 : 1;
  return strcmp(name, r->name);
}

/* within a name: narrowest arity first, then by argc_min, then as written */
static int bop_sort_cmp(const void *a, const void *b) {
  int i = *(const int *)a, j = *(const int *)b;
  const BuiltinOp *x = &bop_rows[i], *y = &bop_rows[j];
  int r = bop_cmp_key(x->recv, x->name, y);
  if (r) return r;
  int wx = x->argc_max - x->argc_min, wy = y->argc_max - y->argc_min;
  if (wx != wy) return wx - wy;
  if (x->argc_min != y->argc_min) return x->argc_min - y->argc_min;
  return i - j;
}

static void bop_build_index(void) {
  for (int i = 0; i < BOP_NROWS; i++) bop_index[i] = i;
  qsort(bop_index, BOP_NROWS, sizeof bop_index[0], bop_sort_cmp);
  bop_indexed = 1;
}

static int bop_row_fits(const BuiltinOp *r, int argc, int has_block) {
  if (argc < r->argc_min || argc > r->argc_max) return 0;
  if (r->block == BF_NONE && has_block) return 0;
  if (r->block == BF_REQUIRED && !has_block) return 0;
  return 1;
}

const BuiltinOp *bop_find(TyKind rt, const char *name, int argc, int has_block) {
  return bop_find_arg(rt, name, argc, has_block, NULL, NULL);
}

const BuiltinOp *bop_find_arg(TyKind rt, const char *name, int argc, int has_block,
                              BopArgKind arg0_of, const void *ud) {
  if (!name) return NULL;
  if (!bop_indexed) bop_build_index();
  int lo = 0, hi = BOP_NROWS;
  while (lo < hi) {
    int mid = lo + (hi - lo) / 2;
    if (bop_cmp_key(rt, name, &bop_rows[bop_index[mid]]) > 0) lo = mid + 1;
    else hi = mid;
  }
  /* rows of one name differ by arity, block form or arg0 guard: take the
     first that fits */
  TyKind a0 = TY_UNKNOWN;
  int a0_known = 0;
  for (int i = lo; i < BOP_NROWS; i++) {
    const BuiltinOp *r = &bop_rows[bop_index[i]];
    if (bop_cmp_key(rt, name, r) != 0) break;
    if (!bop_row_fits(r, argc, has_block)) continue;
    if (r->arg0 != TY_UNKNOWN) {
      if (!arg0_of || argc < 1) continue;
      if (!a0_known) { a0 = arg0_of(ud); a0_known = 1; }
      if (a0 != r->arg0) continue;
    }
    return r;
  }
  return NULL;
}

int bop_covers(TyKind rt) {
  if (!bop_indexed) bop_build_index();
  int lo = 0, hi = BOP_NROWS;
  while (lo < hi) {
    int mid = lo + (hi - lo) / 2;
    if (bop_rows[bop_index[mid]].recv < rt) lo = mid + 1;
    else hi = mid;
  }
  return lo < BOP_NROWS && bop_rows[bop_index[lo]].recv == rt;
}
