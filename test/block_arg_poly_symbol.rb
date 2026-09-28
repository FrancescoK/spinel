# `m(&v)` where v is a boxed value that holds a Symbol at run time. `&:name`
# with a literal is lowered to the block `{ |_spx| _spx.name }` before the
# program is parsed, but a Symbol read out of a poly value is known only at
# run time, and the conversion to a block raised TypeError ("callable object
# is expected") at every site that takes one. The Symbol literals that flow
# into the value each get the proc `&:name` makes, and the value picks its
# own at run time; a Proc, a Method or nil in the same value converts as
# before. A Symbol-typed value that is not a local (`&(c ? :a : :b)`) had no
# arm at all: the method ran without its block and answered as if none was
# given.
def kc(x, &b) = b ? b.call(x) : :none
def ky(x) = block_given? ? yield(x) : :none

class Obj
  def m(x, &b) = b ? b.call(x) : :none
  def self.cm(x, &b) = b ? b.call(x) : :none
end

class Base
  def m(x, &b) = b ? b.call(x) : :none
end

class Sub < Base
  def m(x, &b) = super(x, &[:succ, b][ARGV.size])
end

class SymSub < Base
  def m(x, &b) = super(x, &(ARGV.empty? ? :succ : :pred))
end

class Keep
  def initialize(&b) = @b = b
  def go(x) = @b ? @b.call(x) : :none
end

def kind(i) = i.zero? ? :succ : :pred

class Pt
  def initialize(x) = @x = x
  def x = @x
end

pr = proc { |v| v * 10 }

# the element read out of an Array literal
p kc(3, &[:to_s, 1][0])
p ky(3, &[:to_s, 1][0])
p [1, 2].map(&[:succ, pr][0])

# through a local, at each kind of site
s = [:succ, :to_s, pr][ARGV.size]
p kc(3, &s)
p ky(3, &s)
p [1, 2].map(&s)
p Obj.new.m(3, &s)
p Obj.cm(3, &s)
p method(:kc).call(3, &s)
p Keep.new(&s).go(3)
p Sub.new.m(3)
p [Pt.new(1), Pt.new(2)].map(&[:x, 1].first)

# the run-time value picks its own proc among several
ops = [:succ, :pred, :to_s, pr, nil]
ops.each_index { |i| p kc(7, &ops[i]) }
ops.each_index { |i| p ky(7, &ops[i]) }

# a local assigned in both arms of a conditional, and a constant
t = ARGV.empty? ? :abs : pr
p kc(-4, &t)
OPS = [:even?, :odd?, pr]
p [1, 2, 3].map(&OPS[1])
p [1, 2, 3].select(&OPS[0])

# inside a block body, one value per iteration
3.times { |i| f = [:succ, pr, nil][i]; p kc(5, &f) }

# a unary operator, which `&:-@` spells too
p [3, 1, 2].sort_by(&[:-@, pr][0])

# a Symbol naming a method the receiver lacks raises NoMethodError, as CRuby
begin
  p kc(3, &[:nope, pr][0])
rescue NoMethodError => e
  puts e.message
end

# a Symbol-typed value that is not a local, at each kind of site
p kc(3, &(ARGV.empty? ? :to_s : :succ))
p kc(3, &(!ARGV.empty? ? :to_s : :succ))
p ky(3, &(ARGV.empty? ? :to_s : :succ))
p ky(3, &(!ARGV.empty? ? :to_s : :succ))
p [1, 2].map(&(ARGV.empty? ? :to_s : :succ))
p [1, 2].map(&(!ARGV.empty? ? :to_s : :succ))
p Obj.new.m(3, &(ARGV.empty? ? :to_s : :succ))
p Obj.cm(3, &(ARGV.empty? ? :to_s : :succ))
p method(:kc).call(3, &(ARGV.empty? ? :to_s : :succ))
p Keep.new(&(ARGV.empty? ? :to_s : :succ)).go(3)
p SymSub.new.m(3)
p kc(3, &%i[pred succ][ARGV.size])
p [1, 2].map(&%i[pred succ][ARGV.size])

# and one whose Symbol no literal names here: a method's result
p kc(3, &kind(ARGV.size))
p ky(3, &kind(ARGV.size))
p [1, 2].map(&kind(ARGV.size))

# an iterator that calls its block with two values sends the second to the
# first, as `inject(&:concat)` does in CRuby
s2 = [:concat, 1][0]
p [[1], [2], [3]].inject(&s2)
p [12, 18].reduce(&(ARGV.empty? ? :gcd : :lcm))
p [12, 18].reduce(&(!ARGV.empty? ? :gcd : :lcm))

# the value is read where the call runs: not at all in a branch not taken,
# and afresh on every test of a loop's condition
def side(v) = (puts "side"; v)
no = ARGV.size > 0
p(no && kc(3, &side(:to_s)))
p(no && kc(3, &(puts "side"; [:to_s, 1][0])))
p(no && kc(3, &(puts "side"; no ? :to_s : :succ)))
p((no and kc(3, &(puts "side"; [:to_s, 1][0]))))
p(!no || kc(3, &(puts "side"; [:to_s, 1][0])))
p(no ? kc(3, &(puts "side"; [:to_s, 1][0])) : :skipped)
p(unless !no then kc(3, &(puts "side"; [:to_s, 1][0])) else :skipped end)
r = :skipped
r = kc(3, &(puts "side"; [:to_s, 1][0])) if no
p r
p(case ARGV.size when 1 then kc(3, &(puts "side"; [:to_s, 1][0])) else :skipped end)
p(begin; :ok; rescue; kc(3, &(puts "side"; [:to_s, 1][0])); end)
o = nil
p o&.fetch(0, &(puts "side"; [:to_s, 1][0]))
i = 0
i += 1 while kc(i, &(i < 3 ? :integer? : :zero?))
p i
j = 0
j += 1 until kc(j, &(j < 3 ? :nil? : :integer?))
p j
k = 0
begin; k += 1; end while kc(k, &(k < 3 ? :positive? : :zero?))
p k
w = [:positive?, pr]
n = 0
while kc(n, &w[0]) || n == 0
  n += 1
  w = [:zero?, pr] if n == 2
end
p n
