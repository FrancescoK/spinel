# The `self` of `def self.m` names where m is defined and is no class value
# handed on, so a class with a class method does not escape by it, and an
# unrelated `k.new(x)` on a class value binds only into the classes it can
# reach (#5272, after #5217 and #5271).
class Digest
  def self.valid?(h)
    h.length == 3
  end

  def initialize(raw_hash)
    @raw = raw_hash.to_s
  end

  def to_s
    @raw
  end
end

class Get
  def initialize(url)
    @url = url
  end
end

def request(request_class, url)
  request_class.new(url)
end

request(Get, ARGV.empty? ? :sym : 7)
puts Digest.new("abc").to_s
puts Digest.valid?("abc")
