# Nil-narrowing probe: a fact that proves an Integer or Float local non-nil,
# a breaker between it and the read, CRuby against spinel, case by case.
#
#   ruby tools/nil_narrowing_probe.rb [--strength T | --random N] [--seed S]
#                                     [--strength3 F,F,F..] [--only F=L,..]
#                                     [--batch B] [--jobs J] [--out DIR]
#                                     [--timeout SEC] [--keep] [--no-reduce]
#
# Takes the cases of tools/nil_narrowing_gen.rb -- a covering array of
# strength T (default 2) over the fact (a guard, a write, the found-flag
# window, an in-bounds index read), the breaker that may undo it and the
# loop or block it runs in, the read, the local carrying the value, its
# type, and for an index read the array's slot, a call that may answer the
# array and its block's parameters, where that answer is held, whether the
# call is made on what is held, and the write through it, with every 3-way
# combination of the factors --strength3 names on top (default
# alias_op,alias_way,recv,type; an empty list for none), or N random rows,
# with --only pinning factors to a level each -- runs them B to a program
# under CRuby and under spinel, and compares each case's lines. A case runs
# four times, the fact kept and broken, so a difference is named by the run
# of the first line that differs (`break: value` is a nil the breaker left
# that read as something else) and how it differs. An exception CRuby raises
# is part of the expected answer.
#
# The value-flow probe (tools/value_flow_probe.rb) carries a nil to a read
# that must ask for it; this one proves the nil away first, which is where a
# wrong proof answers silently.
#
# The runner is tools/probe_common.rb's. Output, under DIR (default
# build/nil-narrowing-probe): summary.txt and <label>/case_<id>.rb.
#
# Exit status: 0 no wrong answer, 1 a wrong answer, 4 the tool's own error.

require_relative "nil_narrowing_gen"

# A name the generator defines, undefined: the program is wrong, not spinel
# (a local, a helper method it calls, or a class or a Struct). The cases
# print a NameError's message and only the class of anything else.
UNDEFINED = Regexp.union(/NameError: undefined local variable or method '[a-z]+\d*'[^\n]*/,
                         /NameError: uninitialized constant [A-Z]\d+[^\n]*/)

exit ProbeCommon.main(NilNarrowingGen, "nil_narrowing_probe", ARGV,
                      out: File.expand_path("../build/nil-narrowing-probe", __dir__), strength: 2,
                      undefined: UNDEFINED, also: NilNarrowingGen::ALSO)
