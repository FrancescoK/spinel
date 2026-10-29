# PP.new takes the output, the width and the newline, as PrettyPrint.new
# does: a library makes its own printer with `PP.new(out, width)` (irb's
# ColorPrinter), lays a value out inside guard_inspect_key, and reads the
# layout back from `out`.
require "pp"

s = String.new
q = PP.new(s, 10)
q.guard_inspect_key { q.pp((1..5).to_a) }
q.flush
p s

q = PP.new($stdout, 80)
q.pp({ a: 1, b: [2, 3] })
q.flush
puts

q = PP.new(String.new, 12, "|")
q.pp(%w[alpha beta gamma])
q.flush
p q.output

class Printer < PP
  def initialize(out, width)
    super(out, width)
  end
end
s = String.new
Printer.new(s, 79).tap { |pr| pr.pp([1, "two", :three]) }.flush
p s

PP.pp([1, 2], $stdout)
p PP.new.output
