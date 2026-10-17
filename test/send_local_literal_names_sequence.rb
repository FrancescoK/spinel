# A send whose name is a local assigned a conditional between literal names
# reaches only those methods, as send_local_literal_names.rb shows. An arm
# that is a sequence of several statements, `(note = 1; :assert_match)`, is
# the name its last statement gives; the arm was read only when it held one
# statement, so the send kept every literal of the program as its arms, and
# Kernel's private build_case, which `private :build_case` spells, was
# compiled and refused.
module Kernel
  def build_case(sup, _label = nil) = Class.new(sup) { }
  private :build_case
end

class Check
  def assert_match(a, b) = "match #{a.inspect} #{b}"
  def assert_equal(a, b) = "equal #{a} #{b}"

  def run(exp)
    msg = (Regexp === exp ? (note = 1; :assert_match) : :assert_equal) if exp
    send msg, exp, 1 if msg
  end

  def pick(flag)
    name = (note = 2; :assert_equal)
    name = (note = 3; "assert_match") unless flag
    __send__(name, flag, 2)
  end
end

c = Check.new
p c.run(/x/)
p c.run(2)
p c.run(nil)
p c.pick(true)
p c.pick(false)
