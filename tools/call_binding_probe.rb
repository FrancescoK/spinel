# Call-binding probe: generated calls, CRuby against spinel, case by case.
#
#   ruby tools/call_binding_probe.rb [--strength T | --random N] [--seed S]
#                                    [--only F=L,..] [--batch B] [--jobs J]
#                                    [--out DIR] [--timeout SEC] [--keep]
#                                    [--no-reduce]
#
# Takes the cases of tools/call_binding_gen.rb -- a covering array of strength
# T (default 3) over its factors, or N random rows, with --only pinning
# factors to a level each (a case that cannot take one is left out) -- runs
# them B to a program under CRuby and under spinel, and compares each case's
# lines. The cases of one program share the mode spinel compiles them in (the
# `mode` factor: --int-overflow=promote or not), so the batches are made per
# mode. An exception CRuby raises is part of the expected answer: spinel has
# to raise the same one, after running the same arguments. A case's line is
# its answer and the order its arguments ran in, so a difference is a raise,
# another answer (and the first place in it that binds wrong) or only another
# order.
#
# The runner, shared with tools/value_flow_probe.rb, is tools/probe_common.rb:
# it splits a failing program to the case that carries it, reduces each
# finding toward the simplest levels of the factors, and sorts the findings
# into tiers, families and shapes. Output, under DIR (default
# build/call-binding-probe): summary.txt and <label>/case_<id>.rb.
#
# Exit status: 0 no wrong answer, 1 a wrong answer, 4 the tool's own error.

require_relative "call_binding_gen"
require_relative "probe_common"

# Differences docs/limitations.md gives as the answer on purpose (see
# ProbeCommon::Probe#initialize). None stands now: the bound-Method declines
# it listed bind as CRuby does.
DOCUMENTED = [].freeze

# A name the generator defines, undefined: the program is wrong, not spinel
# (a local, a helper method it calls -- g, gr, fw, q, w, y, rc -- or a class
# or module).
UNDEFINED = Regexp.union(/NameError: undefined local variable or method '(?:blk|kb|lp|[a-z])\d+(?:_\d+)?'[^\n]*/,
                         /NoMethodError: undefined method '(?:[gqwy]|gr|fw|rc)\d+(?:_\d+)?'[^\n]*/,
                         /NameError: uninitialized constant [A-Z]+\d+(?:_\d+)?[^\n]*/)

exit ProbeCommon.main(CallBindingGen, "call_binding_probe", ARGV,
                      out: File.expand_path("../build/call-binding-probe", __dir__), strength: 3,
                      undefined: UNDEFINED, documented: DOCUMENTED)
