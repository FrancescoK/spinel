# A boxed receiver's gsub / sub with a String pattern and a boxed
# replacement. The replacement is `value.to_s`, boxed because one class's
# to_s answers whatever it holds; the receiver is boxed because a class of
# the program defines its own gsub (and, for sub, because the helper is
# also handed an Integer). The String arm had no form for a boxed
# replacement and raised NoMethodError naming String.
class SafeBuffer
  def initialize(s) = @s = s
  def gsub(pat, rep) = SafeBuffer.new(@s.gsub(pat, rep))
  def to_s = @s
end

class Label
  def initialize(v) = @v = v
  def to_s = @v
end

def interpolate(text, options)
  options.each do |name, value|
    text = text.gsub("%{#{name}}", value.to_s)
  end
  text
end

def interpolate_once(text, options)
  options.each do |name, value|
    text = text.sub("%{#{name}}", value.to_s)
  end
  text
end

p interpolate("Hello %{name}, %{name}", { name: "bob" })
p interpolate("Hi %{who}", { who: Label.new("ann") })
p interpolate(SafeBuffer.new("x %{a}"), { a: "2" }).to_s
p interpolate_once("%{n} and %{n}", { n: Label.new("one") })
p interpolate_once("%{n}", { n: 7 })

# a replacement that is not a String at run time is a TypeError
begin
  interpolate("v=%{v}", { v: Label.new(3) })
rescue TypeError => e
  p [e.class, e.message]
end

# a receiver that is not a String is NoMethodError, asked before the
# replacement is converted
begin
  interpolate_once(5, { v: Label.new(3) })
rescue NoMethodError => e
  p [e.class, e.message]
end
