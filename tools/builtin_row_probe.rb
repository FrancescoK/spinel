# Builtin-row probe: each builtin method row of src/builtin_ops.c called
# with its receiver and arguments varied, CRuby against spinel, case by case.
#
#   ruby tools/builtin_row_probe.rb [--strength T | --random N] [--seed S]
#                                   [--ops RE] [--shard I/N]
#                                   [--only F=L,..] [--batch B] [--jobs J]
#                                   [--out DIR] [--timeout SEC] [--keep]
#                                   [--no-reduce] [--no-confirm]
#
# Takes the cases of tools/builtin_row_gen.rb -- for each op (a receiver
# family, a method name a row serves it and a count of arguments with a
# baseline call CRuby answers), a covering array of strength T (default 2)
# over the receiver's form (typed, boxed, a wrong class or nil read out of
# a mixed Array, a nil-or-value local, through an RBS-typed identity), the
# family's sample receiver, each argument's form (typed, boxed, nil, a
# wrong class, boxed), the wrong class, the count (the baseline's, one
# more, one less), the block, a log of the operands' evaluation, and the
# mode -- or N random rows; --ops keeps the ops matching RE ("Array#zip/1"),
# --shard I/N the I-th of N slices of them (0-based), --only pins factors.
# It runs them B to a program under CRuby and under spinel and compares
# each case's lines: its answer (a value's inspect, or an exception's class
# and message), then the log of its operands in the order they ran and of
# what the block was given. A difference is named by the first line that
# differs: `raise-class(ArgumentError->NoMethodError)`, `no-raise(...)`,
# `value`, or `log` (an operand evaluated out of order or skipped).
#
# The flow probes (call binding, value flow, nil narrowing) carry values to
# a few calls; this one takes the calls themselves, row by row, which is
# where an option count, an epsilon of another class or a receiver checked
# before its arguments answer wrong.
#
# The runner is tools/probe_common.rb's. Output, under DIR (default
# build/builtin-row-probe): summary.txt, rows.txt (the rows a case takes,
# and why the others have none) and <label>/case_<id>.rb.
#
# Exit status: 0 no wrong answer, 1 a wrong answer, 4 the tool's own error.

require_relative "builtin_row_gen"

# A name the generator defines, undefined: the program is wrong, not spinel.
UNDEFINED = Regexp.union(/NameError: undefined local variable or method '(?:brp\w*|log|r|a\d|x)'[^\n]*/,
                         /NoMethodError: undefined method '(?:brp\d+|brp_rbs_\w+|brp_norm)'[^\n]*/)

# The rows a case takes (its family, name and a count in its range), and
# for the others why none does.
def rows_report(ops)
  have = ops.map { |op| BuiltinRowGen.op_parts(op) }
  lines = []
  why = Hash.new(0)
  BuiltinRowGen.rows.each do |r|
    fams = BuiltinRowGen.families_of(r.kind)
    reason = if fams.empty? then "no receiver family for #{r.kind}"
             elsif fams.all? { |f| BuiltinRowGen.skip?(f, r.name) } then "skipped (identity, time, a wait or a random draw)"
             elsif have.none? { |f, n, _| fams.include?(f) && n == r.name } then "no CRuby baseline"
             elsif have.none? { |f, n, c| fams.include?(f) && n == r.name && c.between?(r.min, r.max) }
               "no baseline in the row's counts"
             end
    if reason
      why[reason.sub(/ for TY_\w+/, "")] += 1
      lines << format("  %-22s %-16s %-24s %d..%s  %s", r.at, r.kind, r.name, r.min, r.max == 127 ? "any" : r.max,
                      reason)
    end
  end
  total = BuiltinRowGen.rows.size
  head = ["#{total} rows; #{total - lines.size} take a case in this run, #{lines.size} do not:"]
  head += why.sort_by { |_, n| -n }.map { |k, n| "  #{n} #{k}" }
  (head + ["", "rows without a case:"] + lines).join("\n") + "\n"
end

args = ARGV.dup
re = nil
shard = nil
out = File.expand_path("../build/builtin-row-probe", __dir__)
rest = []
until args.empty?
  a = args.shift
  case a
  when "--ops" then re = Regexp.new(args.shift.to_s)
  when "--shard"
    shard = args.shift.to_s.split("/").map { |x| Integer(x, exception: false) }
    unless shard.size == 2 && shard.all? && shard[1].positive? && (0...shard[1]).cover?(shard[0])
      warn "builtin_row_probe: --shard takes I/N, 0 <= I < N"
      exit 4
    end
  when "--out"
    out = File.expand_path(args[0].to_s)
    rest << a << args.shift.to_s
  else rest << a
  end
end
BuiltinRowGen.choose_ops(re, shard)
status = ProbeCommon.main(BuiltinRowGen, "builtin_row_probe", rest, out: out, strength: 2, undefined: UNDEFINED)
File.write(File.join(out, "rows.txt"), rows_report(BuiltinRowGen.ops(re, shard))) if File.directory?(out) && status != 4
exit status
