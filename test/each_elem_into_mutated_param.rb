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
