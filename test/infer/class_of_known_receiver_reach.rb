# A handed-on `x.class` names x's class or a subclass of it when x is known,
# and `K.superclass` names K's ancestors. Neither lets every class escape,
# so an unrelated `k.new(url)` on a class value binds only into the classes
# it can reach (#5271, after #5217).
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

class Sanitizer
  def initialize(n = 0) = @n = n
  def n = @n
end

class Strict < Sanitizer
end

def request(request_class, url)
  request_class.new(url)
end

def sanitizer_class
  Sanitizer.new.class
end

def strict_class(s)
  s.class
end

p sanitizer_class.new(1).n
p strict_class(Strict.new).new(2).n
p Strict.superclass.new(3).n
p request(Get, ARGV.empty? ? :sym : 7).url
puts Digest.new("abc").to_s
