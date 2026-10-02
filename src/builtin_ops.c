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
};
#define BOP_NROWS ((int)(sizeof bop_rows / sizeof bop_rows[0]))

/* Row indices sorted by (receiver kind, name), built on first use. */
static int bop_index[BOP_NROWS];
static int bop_indexed;

static int bop_cmp_key(TyKind rt, const char *name, const BuiltinOp *r) {
  if (rt != r->recv) return rt < r->recv ? -1 : 1;
  return strcmp(name, r->name);
}

static int bop_sort_cmp(const void *a, const void *b) {
  const BuiltinOp *x = &bop_rows[*(const int *)a], *y = &bop_rows[*(const int *)b];
  int r = bop_cmp_key(x->recv, x->name, y);
  return r ? r : x->argc_min - y->argc_min;
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
  if (!name) return NULL;
  if (!bop_indexed) bop_build_index();
  int lo = 0, hi = BOP_NROWS;
  while (lo < hi) {
    int mid = lo + (hi - lo) / 2;
    if (bop_cmp_key(rt, name, &bop_rows[bop_index[mid]]) > 0) lo = mid + 1;
    else hi = mid;
  }
  /* rows of one name differ by arity or block form: take the first that fits */
  for (int i = lo; i < BOP_NROWS; i++) {
    const BuiltinOp *r = &bop_rows[bop_index[i]];
    if (bop_cmp_key(rt, name, r) != 0) break;
    if (bop_row_fits(r, argc, has_block)) return r;
  }
  return NULL;
}

int bop_covers(TyKind rt) {
  for (int i = 0; i < BOP_NROWS; i++) if (bop_rows[i].recv == rt) return 1;
  return 0;
}
