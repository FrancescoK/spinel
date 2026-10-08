# Flag-only: Kernel#String keeps a boxed String's handle and frozen mark.
# Non-String boxes still use the ordinary conversion, evaluated once.
class BoxedStringConversion
  def run
    h = { k: "a\0bc" }
    t = String(h[:k])
    p h[:k].frozen?, t.frozen?, h[:k].equal?(t)
    begin
      t.prepend("p")
    rescue => e
      p e.class
    end
    p [h[:k], t]

    a = [+"abc"]
    u = String(a[0])
    u << "!"
    p a[0].equal?(u), [a[0], u]
    String(a[0]).prepend("p")
    p [a[0], u]
  end
end

class StringConversionSource
  def to_str
    puts "to_str"
    "converted"
  end
end

def convert_box(v)
  t = String(v)
  t << "!" unless t.frozen?
  p t
end

BoxedStringConversion.new.run
[nil, 12, true, "frozen", StringConversionSource.new].each do |v|
  convert_box(v)
end

# A user conversion that answers a shared String keeps that String.
class ViaToStr
  attr_reader :text
  def initialize(text)
    @text = text
  end
  def to_str
    puts "to_str"
    @text
  end
  def to_s
    puts "wrong to_s"
    "wrong"
  end
end
class ViaToS
  attr_reader :text
  def initialize(text)
    @text = text
  end
  def to_s
    puts "to_s"
    @text
  end
end
def check(x, that)
  result = String(x)
  p result.equal?(that)
  result << "!"
  p [that, result]
end
str_text = +"str"
s_text = +"s"
str_source = ViaToStr.new(str_text)
s_source = ViaToS.new(s_text)
[str_source, nil].each do |source|
  check(source, str_text) unless source.nil?
end
[s_source, nil].each do |source|
  check(source, s_text) unless source.nil?
end

# Fresh conversions keep their own answer, even after a shared read.
class FreshConversion
  attr_reader :text
  def initialize
    @text = +"original"
  end
  def read_text
    @text
  end
  def to_str
    puts read_text
    +"fresh"
  end
end
fresh = FreshConversion.new
[fresh, nil].each do |v|
  unless v.nil?
    result = String(v)
    p result.equal?(fresh.text)
    result << "!"
    p [fresh.text, result]
  end
end

class PlainFreshConversion
  def to_str
    +"plain fresh"
  end
end
[PlainFreshConversion.new, nil].each do |x|
  unless x.nil?
    a = String(x)
    b = String(x)
    p a.equal?(b)
    a << "!"
    p [a, b]
  end
end
class MixedConversion
  def initialize(shared)
    @text = +"held"
    @shared = shared
  end
  def read_text
    @text
  end
  def to_str
    puts read_text
    @shared ? @text : +"fresh"
  end
end
[MixedConversion.new(true), MixedConversion.new(false), nil].each do |x|
  unless x.nil?
    result = String(x)
    result << "!"
    p result
  end
end

# Every possible target must publish its answer before pickup is safe.
[ViaToStr.new(+"other"), PlainFreshConversion.new, nil].each do |source|
  unless source.nil?
    result = String(source)
    result << "!"
    p result
  end
end
class NilConversion
  def initialize
    @text = +"earlier"
  end
  def read_text
    @text
  end
  def to_str
    puts read_text
    return nil if @text.size > 0
    @text
  end
  def to_s
    +"fallback"
  end
end
[NilConversion.new, nil].each do |source|
  unless source.nil?
    result = String(source)
    result << "!"
    p result
  end
end
