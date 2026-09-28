# A const_get with a literal name hands out that one class. A `k.new(x)` on a
# class value elsewhere binds only into the classes it can reach, not into
# every class's initialize, which left an unrelated class's parameter
# untyped (#5217).
class Digest
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

  def url = @url
end

def request(request_class, url)
  request_class.new(url)
end

k = Object.const_get(:Get)
p k.new("u").url
p request(Get, ARGV.empty? ? :sym : 7).url
puts Digest.new("abc").to_s
p Object.const_get("Get").new(3).url
