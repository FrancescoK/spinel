# spinel: share
# A block parameter over an Array of Strings that is passed to a method
# mutating its argument in place takes each element as a String buffer,
# where the C build used to stop (#6038).
def allowed?(s)
  s.downcase!
  s.start_with?("http")
end

class Attr
  def initialize(v)
    @v = v
  end

  def value
    @v
  end
end

p allowed?(Attr.new(+"HTTP://b").value)
[+"HTTP://a", +"javascript:x"].each do |uri|
  p allowed?(uri)
end

# ... and through the builtins that yield the element on, each_with_index
# and each_with_object (#6039)
def allowed_dup?(s)
  s = s.dup
  s.downcase!
  s.start_with?("http")
end
p allowed_dup?(Attr.new(+"HTTP://b").value)
["HTTP://a", "javascript:x"].each_with_index do |uri, i|
  p [allowed_dup?(uri), i]
end
["HTTP://c"].each_with_object([]) do |uri, acc|
  p allowed_dup?(uri)
end
