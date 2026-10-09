# Arity rechecks keep an already-converted double splat well typed.
# spinel: gc-minor
# spinel: share
$kw_calls = 0
def kw_operand(v)
  $kw_calls += 1
  v
end
class NoKeywords
  def take(*rest, **nil) = yield
end
[true, false, 1, :symbol, "string", [1], nil].each do |value|
  begin
    p NoKeywords.new.take(x: 1, **kw_operand(value)) { :block }
  rescue => e
    puts e.class
    puts e.message
  end
end
begin
  p NoKeywords.new.take(x: 1, **kw_operand(true)) { :block }
rescue => e
  puts e.class
  puts e.message
end
begin
  p NoKeywords.new.take(x: 1, **1) { :block }
rescue => e
  puts e.class
  puts e.message
end
begin
  p NoKeywords.new.take(x: 1, **nil) { :block }
rescue => e
  puts e.class
  puts e.message
end
p $kw_calls
def top_take(*rest, **nil) = yield
begin
  p top_take(1, z: 5, **true) { :block }
rescue => e
  puts e.class
  puts e.message
end
# A nilable operand reaches the arity check only as nil.
def maybe_int(i) = i > 0 ? i : nil
[0, 1].each do |i|
  begin
    p top_take(z: 5, **maybe_int(i)) { :block }
  rescue => e
    puts e.message
  end
  begin
    p top_take(2, **maybe_int(i)) { :block }
  rescue => e
    puts e.message
  end
end
