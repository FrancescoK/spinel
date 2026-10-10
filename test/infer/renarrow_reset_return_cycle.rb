# The re-narrow loop resets a boxed return that feeds the ivar its call
# reads (`@a = shifted(op, @a, carry)`), and infer_return_types re-derives
# it every iteration. That counted as a change outside the re-derived
# slots, so the fixed-cycle exit never fired: with a Data whose members
# re-derive to nothing, the loop ran its whole 128-iteration cap while the
# state stood still, and the program compiled to the same C three times
# slower.
Setup = Data.define(:model, :size)

class Setup
  def self.read(vals) = new(model: %i[a b].fetch(vals[0]), size: vals[1].zero? ? nil : vals[1])
end

class Cpu
  def initialize
    @a = 1
    @f = 0
  end

  attr_reader :a

  def rotate_a(op)
    carry = op.even? ? @a >> 7 : @a & 1
    @a = shifted(op, @a, carry)
  end

  def shift(op, value) = shifted(op, value, 0)

  def shifted(op, value, carry)
    case op
    when 0 then ((value << 1) | carry) & 0xff
    when 2 then ((value << 1) | (@f & 1)) & 0xff
    else value >> 1
    end
  end
end

st = Setup.read([1, 0])
p st.model, st.size
c = Cpu.new
3.times { c.rotate_a(0) }
p c.a
mixed = [3, "x"]
p c.shift(1, mixed[0])
