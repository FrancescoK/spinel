# A dynamic send whose method answers an Integer or a Float that may be nil:
# the dispatch arm boxed the answer by unwrapping it first, so a nil raised
# TypeError ("no implicit conversion from nil to integer") where CRuby
# answers nil.
class Core
  def initialize
    @plan = [:op_nop, :op_jam, :op_ratio, :op_add]
    @pc = 0
  end

  def op_nop = 1

  def op_jam
    @pc += 1
    @pc > 5 ? @pc : nil
  end

  def op_ratio = @pc > 5 ? 1.5 : nil
  def op_add(n) = @pc > 5 ? @pc + n : nil

  def cycle!(index) = send(@plan[index])
  def cycle_public(index) = public_send(@plan[index])
  def cycle_raw(index) = __send__(@plan[index])
  def cycle_arg(index, n) = send(@plan[index], n)

  def cycle_stmt(index)
    v = send(@plan[index])
    p v
    nil
  end
end

c = Core.new
p c.cycle!(0)
p c.cycle!(1)
p c.cycle_public(1)
p c.cycle_raw(1)
p c.cycle!(2)
p c.cycle_arg(3, 2)
c.cycle_stmt(1)
7.times { c.cycle!(1) }
p c.cycle!(1)
p c.cycle!(2)
p c.cycle_arg(3, 2)
