# A send whose name is a local assigned literal names through a `case`/`when`
# reaches only those methods (send_local_literal_names.rb): Kernel's private
# build_case, which `private :build_case` spells, is not one of its arms, so
# its body, which Spinel would refuse, is not compiled. The assignment was
# not read through a `case`/`when`, so the send kept every literal of the program as
# its arms and compiled build_case.
module Kernel
  def build_case(sup, _label = nil) = Class.new(sup) { }
  private :build_case
end

class Check
  def assert_match(a, b) = "match #{a.inspect} #{b}"
  def assert_equal(a, b) = "equal #{a} #{b}"

  def run(exp)
    msg = case exp
      when Regexp then :assert_match
      else :assert_equal
      end
    send msg, exp, 1
  end
end

c = Check.new
p c.run(/x/)
p c.run(2)
