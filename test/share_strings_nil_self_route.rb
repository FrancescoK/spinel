# Receiver-returning calls keep a shared slot's nil identity. Conversions
# keep their own nil answers, including to_str's NoMethodError.
def pick(i) = i > 0 ? +"ab" : nil
s = pick(ARGV.size)
t = pick(1)
t << "c"
u = t
p s.freeze.equal?(s)
p s.itself.equal?(s)
p t.freeze.equal?(t), u.equal?(t)

p s.equal?(s.freeze), s.equal?(s.itself)
p s.freeze.frozen?, s.itself.frozen?
p s.freeze.object_id == s.object_id, s.itself.__id__ == s.__id__
p s.freeze.object_id == nil.object_id, s.itself.__id__ == nil.__id__
p s.freeze == s, s.itself == s
p t.freeze.object_id == t.object_id, t.itself.__id__ == t.__id__
p t.to_s.equal?(t), t.equal?(t.to_str), t.to_str.frozen?
p t.to_s.object_id == t.object_id, t.to_str.__id__ == t.__id__

p String(s).equal?(s), s.equal?(String(s)), String(s) == s
p String(s) == "", String(s).frozen?
p String(s).object_id == s.object_id, String(s).__id__ == String(nil).__id__
p s.to_s.equal?(s), s.equal?(s.to_s), s.to_s == s
p s.to_s == "", s.to_s.frozen?, s.to_s.object_id == nil.to_s.object_id
begin; p s.to_str; rescue NoMethodError; puts "to_str raises"; end
begin; p s.to_str.equal?(s); rescue NoMethodError; puts "to_str equal? raises"; end
begin; p s.equal?(s.to_str); rescue NoMethodError; puts "equal? to_str raises"; end
begin; p s.to_str.object_id; rescue NoMethodError; puts "to_str object_id raises"; end
begin; p s.to_str.frozen?; rescue NoMethodError; puts "to_str frozen? raises"; end
begin; p s.to_str == s; rescue NoMethodError; puts "to_str == raises"; end
begin; p (+s).equal?(s); rescue NoMethodError; puts "+nil raises"; end
p (+t).equal?(t), String(t).equal?(t)

class NilRouteHolder
  def initialize(i)
    @s = pick(i)
  end
  def check
    alias_s = @s
    alias_s << "c" if alias_s
    p @s.freeze.equal?(@s), @s.equal?(@s.itself)
    p @s.freeze.frozen?, @s.itself.frozen?
    p @s.freeze.object_id == @s.object_id, @s.itself.__id__ == @s.__id__
    p @s.freeze == @s, @s.itself == @s
    p String(@s).equal?(@s), @s.equal?(String(@s)), String(@s) == @s
    p String(@s).object_id == @s.object_id, String(@s).frozen?
    p @s.to_s.equal?(@s), @s.to_s.object_id == @s.object_id, @s.to_s.frozen?
    begin; p @s.to_str.equal?(@s); rescue NoMethodError; puts "ivar to_str equal? raises"; end
    begin; p @s.to_str.__id__ == @s.__id__; rescue NoMethodError; puts "ivar to_str __id__ raises"; end
    begin; p @s.to_str.frozen?; rescue NoMethodError; puts "ivar to_str frozen? raises"; end
    begin; p @s.to_str == @s; rescue NoMethodError; puts "ivar to_str == raises"; end
  end
end
NilRouteHolder.new(0).check
NilRouteHolder.new(1).check
