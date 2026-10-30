# A send of a name the program holds rather than spells reaches an
# Enumerable method written in Ruby -- builtins/enumerable.rb's (tally,
# each_slice) and one a `module Enumerable` reopening adds -- as a written
# call does, and so does a Symbol's to_proc made into its call.

module Enumerable
  def special? = count > 1
end

class Bag
  include Enumerable
  def each
    yield 1
    yield 2
    yield 3
  end
end

class Own
  include Enumerable
  def each = yield(1)
  def special? = :own
end

a = [1, 2]
m = :special?
p a.public_send(m), a.send(m), a.__send__(m)
p({x: 1, y: 2}.public_send(m), (1..1).public_send(m))
p Bag.new.public_send(m), Own.new.public_send(m)
p [[1], [2, 3]].map(&m)
p m.to_proc.call(a), :special?.to_proc.call([1]), m.to_proc.call(Bag.new)
pr = :special?.to_proc
p pr.call([1, 2, 3])

# computed: the arms are the class's methods, the reopening's among them
sfx = "ial?"
p a.public_send("spec#{sfx}"), {x: 1}.public_send(("spec" + "ial?").to_sym)
p (1..3).public_send("spec#{sfx}")

# builtins/enumerable.rb's own methods
t = :tally
p [1, 1, 2].public_send(t), {a: 1}.public_send(t), [[1, 1], "x"][0].public_send(t)
p [[1, 1], [2]].map(&t), t.to_proc.call([3, 3]), :tally.to_proc.call([4])
p [1, 1, 2].public_send(("ta" + "lly").to_sym)
s = :each_slice
p [1, 2, 3].public_send(s, 2).to_a
f = :filter_map
p [1, 2, 3].public_send(f) { |x| x * 2 if x.odd? }

# a receiver that is no Enumerable still raises, boxed or typed
[["ab", m], ["ab", ("spec" + "ial?").to_sym], [:s, m]].each do |r, n|
  begin
    r.public_send(n)
  rescue NoMethodError => e
    p e.message
  end
end
[-> { 3.public_send(t) }, -> { "ab".public_send(m) }].each do |f|
  f.call
rescue NoMethodError => e
  p e.message
end

# a written call of the reopening's method on a boxed receiver too: an
# Array answers through the reopening, a String raises NoMethodError
[[1, 2], "ab", 7].each do |r|
  p r.special?
rescue NoMethodError => e
  p e.message
end

# a computed name sent to a boxed value, whose arms are builtins' as well:
# the arms that take a copy leave the others' receiver as it was
p [:abc, "ab"].map(&("si" + "ze").to_sym)
p [[1, 2], "x"][0].public_send("spec#{sfx}"), [{a: 1, b: 2}, 3][0].public_send("spec#{sfx}")

# an alias the definition has under another name: collect_concat is
# flat_map, detect find -- held, or a literal send's -- unless the
# receiver's class defines the alias itself
cc = :collect_concat
p [[1], [2]].public_send(cc) { |x| x }, {a: [1]}.public_send(cc) { |k, v| v }
dt = :detect
p [1, 2, 3].public_send(dt) { |x| x > 1 }, [1, 2, 3].send(:detect) { |x| x > 1 }
p [[1], [2]].public_send(:collect_concat) { |x| x }
class Det
  include Enumerable
  def each = yield(5)
  def detect = :own
end
p Det.new.public_send(dt), Det.new.send(:detect)

# a copy several held sends share keeps the arm that reads an argument one
# of them passes and another omits
h = {}
p [2].public_send(t, h), h, [1, 1].public_send(t)

# on a boxed value, only an Enumerable takes the reopening's method:
# a Struct and a program class with Enumerable do, a plain object, a
# Regexp, a Rational, a Time or a lambda raises NoMethodError, written or sent
class Plain
  def initialize = @v = 1
end
Pair = Struct.new(:a, :b)
[Pair.new(1, 2), Bag.new, Plain.new, /a/, 1.5r, Time.at(0), -> {}, Dir.new(".")].each do |r|
  got = [-> { r.special? }, -> { r.public_send(m) }].map do |f|
    f.call
  rescue NoMethodError => e
    e.message.sub(/ for .*/, "")
  end
  p got
end

# a class of the program that defines an alias itself keeps its method, and
# an Array's collect_concat or detect still reaches the builtin's, written,
# held or sent
class CC
  include Enumerable
  def each = yield(1)
  def collect_concat = :own
end
class Plain2
  def detect = :plain
end
p [[1], [2]].collect_concat { |x| x }, [[1], [2]].public_send(cc) { |x| x }, [[1], [2]].send(:collect_concat) { |x| x }
p CC.new.public_send(cc), CC.new.send(:collect_concat)
[Det.new, [1, 2], Plain2.new].each do |v|
  p [v.detect { |e| e > 1 }, v.public_send(dt) { |e| e > 1 }]
end
