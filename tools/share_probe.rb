# String-sharing probe: a mutable String carried from one holder to a
# second name by every route, mutated through one name and read through the
# other, CRuby against spinel, case by case.
#
#   ruby tools/share_probe.rb [--strength T | --random N] [--seed S]
#                             [--shard I/N] [--only F=L,..] [--batch B]
#                             [--jobs J] [--out DIR] [--timeout SEC] [--keep]
#                             [--no-reduce] [--no-confirm]
#
# Takes the cases of tools/share_gen.rb -- a covering array of strength T
# (default 2) over what holds the String first (a local, an instance, class
# or global variable, a constant, an Array element, a Hash value, a Struct
# member, a block's or a method's parameter, a captured local, an
# attr_accessor), the route that carries it to a second name (48: method
# returns, block and break values, catch/throw, Thread#value, Fiber#resume,
# Method#call, super, send, a poly call, `+s`, String(s), `||=`, multiple
# assignment, splats, keyword and default arguments, containers stored and
# read back, a pattern, an exception's message, instance_variable_get, and
# the copies dup, clone and String.new), the mutation (13 bang methods and
# setters), the name it goes through, the read that observes both names
# (`p`, equal?, object_id ==, frozen?, size), how the String is made (`+`
# of a literal, an interpolation, a frozen literal) -- or N random rows.
# --shard I/N keeps every N-th row from the I-th (0-based),
# under the case numbers of the whole run, so a case file names the same
# case in each shard and each run of one seed.
#
# CRuby runs each program with its literals frozen (the corpus's oracle is
# `ruby --enable-frozen-string-literal`; the programs say
# `# frozen_string_literal: true`). Every String is one handle in every
# holder (#9258), and a route that hands over a copy instead loses a
# mutation without a word. A
# finding's kind names the last line, `p` of both names, when it differs
# (`value: value@0` is a mutation the holder did not see, `value@1` one the
# second name did not, or saw where CRuby copies), else the first line that
# differs (`before: value` is an identity read, `mutation: value` a
# mutation that raised or did not).
#
# The runner is tools/probe_common.rb's: it splits a failing program to the
# case that carries it, reduces each finding toward the simplest levels of
# the factors (--no-reduce skips it), and sorts the findings into tiers,
# families and shapes. Output, under DIR (default build/share-probe):
# summary.txt and <label>/case_<id>.rb.
#
# Exit status: 0 no wrong answer, 1 a wrong answer, 4 the tool's own error.

require_relative "share_gen"

# A name the generator defines, undefined: the program is wrong, not spinel.
UNDEFINED = Regexp.union(/NameError: undefined local variable or method '[a-z]\w*'[^\n]*/,
                         /NoMethodError: undefined method '(?:r\d+|body\d+|run)'[^\n]*/,
                         /NameError: uninitialized constant SP\d+[^\n]*/)

args = ARGV.dup
rest = []
until args.empty?
  a = args.shift
  if a == "--shard"
    shard = args.shift.to_s.split("/").map { |x| Integer(x, exception: false) }
    unless shard.size == 2 && shard.all? && shard[1].positive? && (0...shard[1]).cover?(shard[0])
      warn "share_probe: --shard takes I/N, 0 <= I < N"
      exit 4
    end
    ShareGen.shard = shard
  else
    rest << a
  end
end
exit ProbeCommon.main(ShareGen, "share_probe", rest, out: File.expand_path("../build/share-probe", __dir__),
                      strength: 2, undefined: UNDEFINED)
