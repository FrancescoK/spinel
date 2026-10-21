# spinel: share
# Integer.sqrt raises FloatDomainError for a non-finite Float, native or
# boxed, before truncating it; a finite Float still truncates first.
def try_sqrt(x)
  p Integer.sqrt(x)
rescue => e
  p [e.class, e.message]
end

begin
  p Integer.sqrt(Float::INFINITY)
rescue => e
  p [e.class, e.message]
end
begin
  p Integer.sqrt(Float::NAN)
rescue => e
  p [e.class, e.message]
end
begin
  p Integer.sqrt(-Float::INFINITY)
rescue => e
  p [e.class, e.message]
end

[Float::INFINITY, Float::NAN, -Float::INFINITY, 9.0, -0.5, 8.9, -1.5, -0.0].each do |x|
  begin
    p Integer.sqrt(x)
  rescue => e
    p [e.class, e.message]
  end
end
[Float::INFINITY, Float::NAN, -Float::INFINITY, 25.0].each { |x| try_sqrt(x) }

[Float::INFINITY, Float::NAN, -Float::INFINITY, 16, "x", nil].each do |x|
  next if x.nil?
  begin
    p Integer.sqrt(x)
  rescue => e
    p [e.class, e.message]
  end
end
[Float::INFINITY, Float::NAN, 9.0, nil].each do |x|
  next if x.nil?
  begin
    p Integer.sqrt(x)
  rescue => e
    p [e.class, e.message]
  end
end

def next_float
  puts "argument"
  Float::NAN
end
begin
  p Integer.sqrt(next_float)
rescue => e
  p [e.class, e.message]
end

p Integer.sqrt(*[25.0])
begin
  Integer.sqrt(*[1.0, 2.0])
rescue => e
  p [e.class, e.message]
end
