# casecmp and casecmp? on a value read out of a mixed Array: a Symbol
# compares with a Symbol and a String with a String (or an object answering
# #to_str); any other operand is nil, and a receiver of another kind still
# raises NoMethodError.
class W
  def to_str = "HELLO"
end

x = [:hello, 1][0]
s = [+"hello", 1][0]
p x.casecmp(:HELLO)
p x.casecmp(:world)
p x.casecmp("HELLO")
p x.casecmp?(:HELLO)
p x.casecmp?("HELLO")
p x.casecmp?(1)
p s.casecmp("HELLO")
p s.casecmp(:HELLO)
p s.casecmp?("HELLO")
p s.casecmp(W.new)
p s.casecmp?(W.new)
p s.casecmp(nil)
p x.casecmp(x)
p (x.casecmp(:HELLO) || 5) + 1
begin
  [1, :a][0].casecmp(:a)
rescue NoMethodError => e
  puts e.message
end
