# A Class object of the program handed to a builtin (a fetch default, a
# block's answer, an element) comes back out as a builtin's answer, and
# `new` on that answer makes an instance of it (#10303).
class A
  def initialize(n = 0) = @n = n
  def call = "A#{@n}"
end

class B < A
  def call = "B#{@n}"
end

class C
  def call = "C"
end

p Hash.new(A)[:x].new(1).call
p Array.new(2, B)[1].new(2).call
p Hash.new { |h, k| C }[:y].new.call
p [A, B].fetch(5) { B }.new(3).call
p({ k: A }.fetch(:z, C).new.call)
p [A].dig(0).new(4).call
p({ a: B }.min_by { |k, v| k }[1].new(5).call)
p [A, B].max_by { |k| k.name }.new(6).call
p({ a: A, b: B }.values.last.new(7).call)
p [[C]].flatten.first.new.call
p Array(B).first.new(8).call
p [A, B].each_slice(1).to_a.last.first.new(9).call
p [B].cycle.first.new(10).call
p [C].find { |x| x.name == "C" }.new.call
p [B.new].first.class.superclass.new(11).call
p [A, B, C].group_by { |x| x.name.size }[1].first.new.call
p({ x: C }.to_a.first.last.new.call)
p [A].zip([B]).first.last.new(12).call
p [B].inject { |m, x| x }.new(13).call
p [C].then { |a| a.first }.new.call
