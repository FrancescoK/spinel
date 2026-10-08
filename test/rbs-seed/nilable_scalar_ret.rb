# An --rbs `Integer?` / `Float?` RETURN must hand back nil, not the type's
# zero. The seed pins the return slot to the unboxed kind, and a bare `nil`
# renders as the numeric default 0 -- a real value in that slot, so the caller
# reads 0 / 0.0 where the method said nil. `bool?` and `String?` are correct
# without help: the poly box and NULL carry nil natively. int and float have a
# reserved sentinel to land on, and every consumer already tests for it, so the
# tail spells the sentinel instead. The return-value counterpart of #3412.
# spinel: rbs-seed-check
class Seed
  def self.i(present); present ? 1 : nil; end
  def self.f(present); present ? 1.5 : nil; end
  def self.b(present); present ? true : nil; end
  def self.s(present); present ? "x" : nil; end
end

vi = Seed.i(false)
vf = Seed.f(false)
vb = Seed.b(false)
vs = Seed.s(false)
puts "i nil?=" + vi.nil?.to_s + " to_s=<" + vi.to_s + ">"
puts "f nil?=" + vf.nil?.to_s + " to_s=<" + vf.to_s + ">"
puts "b nil?=" + vb.nil?.to_s + " to_s=<" + vb.to_s + ">"
puts "s nil?=" + vs.nil?.to_s + " to_s=<" + vs.to_s + ">"

# the present branch is unaffected
puts "i2=" + Seed.i(true).to_s + " f2=" + Seed.f(true).to_s

# The same slot fed from a BOXED value rather than a literal: the ivar holds
# nil natively (it is poly), and the narrowing on the way out is where nil was
# being flattened. This is the shape a nullable foreign key takes -- a reader
# over a boxed column -- and the reason group_by on one found no nil group.
class Row
  def initialize(v); @v = v; end
  def v; @v; end
  def w; @v; end
end
r0 = Row.new(nil)
r1 = Row.new(7)
puts "boxed-nil nil?=" + r0.v.nil?.to_s + " to_s=<" + r0.v.to_s + ">"
puts "boxed-val=" + r1.v.to_s
puts "boxed-f nil?=" + r0.w.nil?.to_s
groups = [r0, r1].group_by { |x| x.v }
puts "nil-group=" + (groups[nil] ? groups[nil].length.to_s : "missing")
