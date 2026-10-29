# spinel: gc-minor
# A boxed value's to_s given as a key beside a value that runs a program method is
# hoisted ahead of the call. It is the receiver's own String when it is one, so a
# setter that changes its key changes that String, as in CRuby. (A Symbol's to_s
# is frozen in Spinel, so the setter changes a copy of a frozen key: `+key` is
# the key itself otherwise.)
class Name
  def initialize(n) = @n = n
  def to_s = "name:#{@n}"
end

class Elem
  def initialize
    @pairs = []
  end

  def []=(key, value)
    key = +key
    key << "!"
    @pairs << [key, value]
    value
  end

  def dump = @pairs.inspect
end

def target(flag) = flag ? Elem.new : {}

def norm(value) = value.is_a?(Integer) ? value + 1 : value

def store(keys, flag)
  out = target(flag)
  keys.each_with_index do |k, i|
    out[k.to_s] = norm(i)
  end
  out
end

a = +"a"
b = +"b"
puts store([a, :s, Name.new(1), b], true).dump
puts a, b
p store([a, :s], false)
