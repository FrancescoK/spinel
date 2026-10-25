# spinel: rbs-seed-run
# A boxed value reaches a parameter the seed types Array[untyped]: an Array
# of any kind, or of an Array subclass, passes, and an object of another
# class raises TypeError at the call, where it was read as a poly array and
# crashed. CRuby, which reads no seed, runs the method on the object; the
# signature is the program's contract here.
class PolySeedItem
  def initialize(n)
    @n = n
  end

  def n
    @n
  end
end

class PolySeedPage < Array
end

class PolySeedRel
  def initialize(items)
    @items = items
  end

  def each(&b)
    @items.each(&b)
  end
end

class PolySeedLoader
  def total(records)
    sum = 0
    records.each { |r| sum += r.n }
    sum
  end
end

def try_total(v)
  p PolySeedLoader.new.total(v)
rescue TypeError => e
  puts "TypeError: #{e.message}"
end

items = [PolySeedItem.new(1), PolySeedItem.new(2)]
try_total([items, 0][0])
try_total([PolySeedPage.new(items), 0][0])
try_total([PolySeedRel.new(items), 0][0])
