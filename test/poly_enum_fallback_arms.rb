# The arm that raises NoMethodError for a boxed object whose class has no
# Enumerable tests the object's class itself, not a program's instance_of?;
# it leaves a Range's blockless minmax to Range (off its endpoints, a Float
# Range included); and Enumerable reached through modules several includes
# share is found.
class Rows              # to_a alone, with an instance_of? that says no
  def initialize(rows) = @rows = rows
  def to_a = @rows
  def instance_of?(k) = false
end

class Coll              # Enumerable, with an instance_of? that says yes
  include Enumerable
  def initialize(rows) = @rows = rows
  def each(&b) = @rows.each(&b)
  def instance_of?(k) = true
end

module Leaf; end
module Root; include Enumerable; end
module Left; include Leaf; include Root; end
module Right; include Leaf; include Root; end
module Top; include Left; include Right; end

class Shared            # Enumerable below two modules that share theirs
  include Top
  def initialize(rows) = @rows = rows
  def each(&b) = @rows.each(&b)
end

class Holder
  def initialize(k)
    @c = case k
         when 0 then [3, 1, 2]
         when 1 then Rows.new([2, 6])
         when 2 then Coll.new([4, 8])
         else Shared.new([5, 9])
         end
  end

  def tallied = @c.tally
  def any = @c.any? { |x| x > 3 }
end

class Pairs             # each alone
  def initialize(rows) = @rows = rows
  def each(&b) = @rows.each(&b)
end

class Span
  def initialize(k)
    @c = case k
         when 0 then (1.0..5.0)
         when 1 then (2..7)
         when 2 then [3, 1, 2]
         else Pairs.new([2, 6])
         end
  end

  def bounds = @c.minmax
end

def try
  p yield
rescue NoMethodError, TypeError => e
  puts "#{e.class}: #{e.message[/\A.*? an instance of \w+/] || e.message}"
end

(0..3).each do |k|
  h = Holder.new(k)
  puts "-- #{k}"
  try { h.tallied }
  try { h.any }
end
(0..3).each { |k| try { Span.new(k).bounds } }
