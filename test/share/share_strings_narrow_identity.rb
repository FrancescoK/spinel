# Flag-only: narrowing a boxed String keeps its shared handle, so mutation
# and identity agree with the value before the guard and its original owner.
def narrow_array(value)
  copy = [value][0]
  if copy.is_a?(String)
    copy << "!"
    p value.equal?(copy)
  end
  p copy
end

def narrow_before(value)
  copy = [value][0]
  p value.equal?(copy)
  if copy.is_a?(String)
    p value.equal?(copy)
    copy << "!"
    p value.equal?(copy)
  end
  p copy
end

def narrow_case(value)
  copy = [value][0]
  case copy
  when String
    copy << "!"
    p value.equal?(copy)
  end
  p copy
end

def narrow_and(value)
  copy = [value][0]
  copy.is_a?(String) && copy << "!"
  p value.equal?(copy), copy
end

def narrow_unless(value)
  copy = [value][0]
  unless copy.is_a?(String)
    p copy
    return
  end
  copy << "!"
  p value.equal?(copy), copy
end

def narrow_hash(value)
  copy = {item: value}[:item]
  if copy.is_a?(String)
    copy << "!"
    p value.equal?(copy)
  end
  p copy
end

# The share rows also identify other calls that hand on a literal's element.
def narrow_reader(value, reader)
  copy = case reader
         when 0 then [value].first
         when 1 then [value].last
         when 2 then [value].fetch(0)
         when 3 then [value].dig(0)
         when 4 then [value].at(0)
         when 5 then [value].sample
         when 6 then {item: value}.fetch(:item)
         when 7 then {item: value}.dig(:item)
         end
  if copy.is_a?(String)
    copy << "!"
    p value.equal?(copy)
  end
  p copy
end

class NarrowHolder
  def initialize(value)
    @value = value
  end

  def touch
    copy = @value
    if copy.is_a?(String)
      copy << "!"
      p @value.equal?(copy)
    end
    p copy, @value
  end
end

def narrow_parameter(copy, original)
  if copy.is_a?(String)
    p original.equal?(copy)
    copy << "!"
    p original.equal?(copy)
  end
  p copy
end

s = +"abc"; narrow_array(s); p s
s = +"abc"; narrow_before(s); p s
s = +"abc"; narrow_case(s); p s
s = +"abc"; narrow_and(s); p s
s = +"abc"; narrow_unless(s); p s
s = +"abc"; narrow_hash(s); p s
s = +"abc"; NarrowHolder.new(s).touch; p s
s = +"abc"; narrow_parameter(s, s); p s
8.times do |reader|
  s = +"abc"
  narrow_reader(s, reader)
  p s
end
narrow_reader(nil, 0)

# Keep the other parameter and element slots boxed, and exercise their
# other arms. narrow_array above also covers a String-only parameter.
narrow_before(nil)
narrow_case(7)
narrow_and(nil)
narrow_unless(7)
narrow_hash(nil)
NarrowHolder.new(7).touch
narrow_parameter(7, 7)

# A plain frozen String in a box stays frozen when narrowed.
begin
  narrow_parameter("frozen", "frozen")
rescue FrozenError
  puts "frozen"
end
