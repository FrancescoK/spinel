# Value-flow probe: a value that may be nil, carried in a typed slot and read,
# CRuby against spinel, case by case.
#
#   ruby tools/value_flow_probe.rb [--strength T | --random N] [--seed S]
#                                  [--only F=L,..] [--batch B] [--jobs J]
#                                  [--out DIR] [--timeout SEC] [--keep]
#                                  [--no-reduce]
#
# Takes the cases of tools/value_flow_gen.rb -- a covering array of strength
# T (default 2) over where the value comes from, what carries it, how it is
# read, the slot's type, whether a written object is frozen first, the scope
# and the mode, or N random rows, with --only pinning factors to a level each
# (a case that cannot take one is left out) -- runs them B to a program under
# CRuby and under spinel, and compares each case's lines. A case prints its
# read of a present value, of the source's value and of a nil its carrier
# makes, so a difference is named by the role of the first line that differs
# (`source: value` is a nil that read as something else) and how it differs.
# An exception CRuby raises is part of the expected answer. The cases of one
# program share the mode spinel compiles them in.
#
# The call-binding probe (tools/call_binding_probe.rb) prints what it binds
# with `inspect`, which already asks a typed slot for its nil; the reads this
# probe crosses with its carriers are the ones that did not.
#
# The runner, shared with the call-binding probe, is tools/probe_common.rb:
# it splits a failing program to the case that carries it, reduces each
# finding toward the simplest levels of the factors, and sorts the findings
# into tiers, families and shapes. Output, under DIR (default
# build/value-flow-probe): summary.txt and <label>/case_<id>.rb.
#
# Exit status: 0 no wrong answer, 1 a wrong answer, 4 the tool's own error.

require_relative "value_flow_gen"

# A name the generator defines, undefined: the program is wrong, not spinel
# (a local, a helper method it calls, or a class or a Struct).
UNDEFINED = Regexp.union(/NameError: undefined local variable or method '[a-z]+\d+'[^\n]*/,
                         /NoMethodError: undefined method '[a-z]+\d+'[^\n]*/,
                         /NameError: uninitialized constant [A-Z]\d+[^\n]*/)

exit ProbeCommon.main(ValueFlowGen, "value_flow_probe", ARGV,
                      out: File.expand_path("../build/value-flow-probe", __dir__), strength: 2,
                      undefined: UNDEFINED)
