# spinel: share
# spinel: gc-minor
# Reopening defaults read the callee with literal and forwarded blocks.
class String
  def read_default(b = self) = b.size
  def upper_default(b = self) = b.upcase
  def empty_default(b = self) = b.empty?
  def size_default(a = size) = yield(a)
end
class Integer
  def next_default(a = self + 1) = yield(a)
end
class Float
  def self_default(b = self) = yield(b.to_s)
end
class Symbol
  def self_default(b = self) = yield(b)
end
class Array
  def tail_default(a = size)
    yield a
  ensure
    puts "array ensure"
  end
end
class Hash
  def size_default(a = size) = yield(a)
end
class Array
  def size_default(a = size) = yield(a)
end
def forwarded_size(receiver, &) = receiver.size_default(&)
def forwarded_tail(receiver, &) = receiver.tail_default(*[], &)
p (+"abc").read_default
p (+"ab").size_default { |v| v }
p forwarded_size(+"abcd") { |v| GC.start; v }
p 3.next_default { |v| v * 2 }
p({a: 1}.size_default { |v| v })
p [].tail_default { |v| v }
a = [0, 1]
p forwarded_tail(a) { |v| GC.start; v }
p a.tail_default(5) { |v| v }

s = +"ab"
s << "c"
p s.size_default { |v| v }
p s.read_default

p 1.5.self_default { |v| v + "!" }
p :ab.self_default { |v| v.to_s }
p [4, 5].size_default { |v| v }

p (+"ab").upper_default
p (+"").empty_default

# a singleton method of a class that returns its parameter after changing it
# is no reopening of a builtin's instance method: it compiles in the default
# build, where the returned String is the one passed in
class File
  def self.readable?(value)
    value << "!"
    value
  end
end
fv = +"readable"
fa = File.readable?(fv)
fa << "?"
p fv
p fa
