# A receiverless call to a private Kernel function in a method a program
# adds to Integer, Float or Comparable reaches Kernel's function when the
# receiver's class does not answer that name itself (no Integer, Float or
# Comparable method is named select, format, rand or sleep), and the
# program's own method when the program defines the name on that class or
# in Comparable (putc, beside select in the same module). A name the
# receiver answers with a method of its own is called on self: Numeric's
# public singleton_method_added raises a TypeError for an Integer or a
# Float, bare in a method of the reopened Integer as well as written with
# its receiver.
class Integer
  def int_select = select(nil, nil, nil, 0).inspect
  def int_format = format("%03d", self)
  def int_rand = rand(1)
  def int_sleep = sleep(0)
  def call_open = open
  def open = self * 10
end

p 12.gcd(8)
p 5.int_select
p 5.int_format
p 5.int_rand
p 5.int_sleep
p 4.call_open

class Float
  def flo_select = select(nil, nil, nil, 0).inspect
  def flo_format = format("%.2f", self)
  def flo_rand = rand(1)
  def flo_sleep = sleep(0)
  def call_open = open
  def open = self * 2
end

p 1.5.flo_select
p 1.5.flo_format
p 1.5.flo_rand
p 1.5.flo_sleep
p 1.5.call_open

module Comparable
  def cmp_select = select(nil, nil, nil, 0).inspect
  def cmp_format = format("<%d>", self)
  def cmp_putc = putc
  def putc = :comparable_putc
end

p 7.clamp(1, 3)
p 7.cmp_select
p 7.cmp_format
p 7.cmp_putc
p 2.5.cmp_putc

class Integer
  def call_added = singleton_method_added(:x)
end

begin; 5.call_added; rescue TypeError => e; p e.message; end
begin; 5.singleton_method_added(:x); rescue TypeError => e; p e.message; end
begin; 1.5.singleton_method_added(:x); rescue TypeError => e; p e.message; end
begin; 5.send(:singleton_method_added, :x); rescue TypeError => e; p e.message; end
begin; 1.5.send(:singleton_method_added, :x); rescue TypeError => e; p e.message; end
