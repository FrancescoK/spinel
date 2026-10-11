# A send whose name is a local every write of which is a literal name (or a
# conditional between them) reaches only those methods: Kernel's private
# build_case, which `private :build_case` spells, is not one of its arms, so
# its body, which Spinel would refuse, is not compiled.
module Kernel
  def build_case(sup, _label = nil) = Class.new(sup) { }
  private :build_case
end

class Check
  def assert_match(a, b) = "match #{a.inspect} #{b}"
  def assert_equal(a, b) = "equal #{a} #{b}"

  def run(exp)
    msg = Regexp === exp ? :assert_match : :assert_equal if exp
    send msg, exp, 1 if msg
  end

  def pick(flag)
    name = :assert_equal
    name = "assert_match" unless flag
    __send__(name, flag, 2)
  end
end

c = Check.new
p c.run(/x/)
p c.run(2)
p c.run(nil)
p c.pick(true)
p c.pick(false)
