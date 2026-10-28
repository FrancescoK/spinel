# Whether a boxed object answers a builtin Enumerable method is asked of its
# class's whole ancestry: a subclass that includes Enumerable answers it
# where its superclass with only an #each raises; an exception with only a
# #to_a raises, as a plain class does; a module chain of any depth brings
# Enumerable; and a forwarded proc raises for a class without Enumerable as
# a literal block does.
class Parent            # each alone
  def initialize(rows) = @rows = rows
  def each(&b) = @rows.each(&b)
end

class Child < Parent    # its subclass, with Enumerable
  include Enumerable
end

class Fault < StandardError   # an exception with to_a alone
  def to_a = [4, 8]
end

module M0; include Enumerable; end
module M1; include M0; end
module M2; include M1; end
module M3; include M2; end
module M4; include M3; end
module M5; include M4; end
module M6; include M5; end
module M7; include M6; end
module M8; include M7; end
module M9; include M8; end
module M10; include M9; end
module M11; include M10; end
module M12; include M11; end
module M13; include M12; end
module M14; include M13; end
module M15; include M14; end
module M16; include M15; end
module M17; include M16; end

class Deep              # Enumerable eighteen modules down
  include M17
  def initialize(rows) = @rows = rows
  def each(&b) = @rows.each(&b)
end

class Holder
  def initialize(k)
    @c = case k
         when 0 then [1, 5]
         when 1 then Child.new([2, 6, 6])
         when 2 then Parent.new([3, 7])
         when 3 then Fault.new("f")
         when 4 then rescued
         else Deep.new([5, 9])
         end
  end

  def rescued
    raise Fault, "r"
  rescue Fault => e
    e
  end

  def any = @c.any? { |x| x > 3 }
  def mapped = @c.map { |x| x + 1 }
  def found = @c.find { |x| x > 3 }
  def chosen = @c.select { |x| x > 3 }
  def folded = @c.inject { |a, x| a + x }
  def tallied = @c.tally
  def any_proc(pr) = @c.any?(&pr)
  def ewi(pr) = @c.each_with_index(&pr)

  def ewi_stmt(pr)
    @c.each_with_index(&pr)
    :walked
  end
end

def try
  p yield
rescue NoMethodError => e
  puts "NoMethodError: #{e.message[/\A.*? an instance of \w+/]}"
end

big = proc { |x| x > 3 }
show = proc { |x, i| print x, ":", i, " " }
(0..5).each do |k|
  h = Holder.new(k)
  puts "-- #{k}"
  try { h.any }
  try { h.mapped }
  try { h.found }
  try { h.chosen }
  try { h.folded }
  try { h.tallied }
  try { h.any_proc(big) }
  try { h.ewi(show); nil }
  try { h.ewi_stmt(show) }
end
