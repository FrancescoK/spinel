# A key that is a boxed value's to_s, given to a setter beside a value that
# runs a program method, is hoisted into a String temp ahead of the call. The
# poly dispatch's arm for a signature-declared parameter then asked the key's
# route again, which read the temp as its handle under --share-strings: the C
# passed a `const char *` where an `sp_String *` was wanted. The key is the
# receiver's own String when it is one, so a setter that changes the key
# changes that String (`a` and `b` below end as "a!" and "b!"); the unresolved
# receiver of from_json (`out` is bound nowhere, so the call never runs) is the
# shape the compiler first met it in.
module HkNokogiri
  class Attr
    def to_s
      ""
    end
  end

  class Element
    def []=(_key, _value)
      _value
    end
  end
end

module HkBuilder
  def self.from_json(params)
    params.each do |k, v|
      out[k.to_s] = HkBuilder.normalize_json(v)
    end
  end

  def self.label(i) = "v" + i.to_s

  def self.normalize_json(value)
    if value.is_a?(Hash)
      out = {}
      value.each do |k, v|
        out[k.to_s] = HkBuilder.normalize_json(v)
      end
      out = []
    end
  end
end

class HkName
  def initialize(n)
    @n = n
  end

  def to_s
    "name:#{@n}"
  end
end

class HkSetter
  def initialize
    @pairs = []
  end

  def []=(key, value)
    key = +key   # (a Symbol's to_s is frozen in Spinel: a copy of it)
    key << "!"
    @pairs << [key, value]
    value
  end

  def dump = @pairs.inspect
end

def hk_target(flag) = flag ? HkSetter.new : {}

def hk_store(keys, flag)
  out = hk_target(flag)
  keys.each_with_index do |k, i|
    out[k.to_s] = HkBuilder.label(i)
  end
  out
end

req = ARGV.empty? ? {} : []
p HkBuilder.from_json(req)
a = +"a"
b = +"b"
puts hk_store([a, :s, HkName.new(1), b], true).dump
puts a, b
p hk_store([a, :s], false)
