# `return enum_for(__method__, args) unless block_given?` in a method that
# takes arguments, or in a class method: the Enumerator calls the method again
# with the same arguments.

# --- a class method with optional and rest parameters (RDoc::RI::Paths.each) ---
module Paths
  def self.each(system = true, site = true, gems = :latest, *extra_dirs)
    return enum_for __method__, system, site, gems, *extra_dirs unless
      block_given?

    extra_dirs.each do |dir|
      yield dir, :extra
    end

    yield "/ri/system", :system if system
    yield "/ri/site", :site if site
    yield "/ri/gems/#{gems}", :gem if gems

    nil
  end
end

Paths.each(true, false, nil, "/x") { |dir, type| p [dir, type] }
p Paths.each.to_a
p Paths.each(false, true, :all, "/a", "/b").map { |dir, _| dir }
p Paths.each(false, false, false).to_a
e = Paths.each(true, true, nil)
p e.class
p e.next
p e.next
begin
  e.next
rescue StopIteration
  puts "stop"
end
p Paths.each.select { |_, type| type == :gem }

# --- a class method with no arguments ---
class Registry
  def self.names
    return to_enum(:names) unless block_given?
    yield "a"
    yield "b"
  end
end
p Registry.names.to_a
p Registry.names.map(&:upcase)

# --- class << self ---
class Store
  class << self
    def each_key(prefix)
      return enum_for(:each_key, prefix) unless block_given?
      %w[x y].each { |k| yield "#{prefix}#{k}" }
    end
  end
end
p Store.each_key("k_").to_a

# --- an instance method with a required argument and a literal ---
class Countdown
  def initialize(from) = @from = from

  def each_step(by, label = "t")
    return enum_for(:each_step, by, label) unless block_given?
    n = @from
    while n > 0
      yield label, n
      n -= by
    end
    self
  end
end
c = Countdown.new(7)
p c.each_step(3).to_a
p c.each_step(2, "s").map { |l, n| "#{l}#{n}" }
p c.each_step(5).with_index.to_a
c.each_step(4) { |l, n| print l, n, "\n" }
p c.each_step(1, "u").first(2)

# --- an included module's method ---
module Walk
  def walk(depth)
    return enum_for(__method__, depth) unless block_given?
    depth.times { |i| yield i * 10 }
  end
end
class Tree
  include Walk
end
p Tree.new.walk(3).to_a
p Tree.new.walk(4).sum

# --- a top-level method ---
def evens(limit, start = 0)
  return to_enum(:evens, limit, start) unless block_given?
  i = start
  while i < limit
    yield i
    i += 2
  end
end
p evens(7).to_a
p evens(9, 4).to_a

# --- the arguments are the ones enum_for was given ---
class Keep
  def each(*xs)
    @kept = xs
    return enum_for(:each, *xs) unless block_given?
    xs.each { |x| yield x }
  end

  def add(x) = @kept << x
end
k = Keep.new
e = k.each(1, 2)
k.add(3)
p e.to_a
p e.to_a
