# A String- or Symbol-keyed write into a Hash keyed by another class (a
# Symbol-keyed Hash's dup, an Integer- or String-keyed one) holds both keys:
# the Hash is poly-keyed, not retyped to the new key's class or left as it was.

def eff(attrs, override)
  result = attrs.dup
  override.each do |k, v|
    if attrs.key?(k.to_sym)
      result[k.to_sym] = v
    else
      result[k.to_s] = v
    end
  end
  result
end
p eff({x: "1"}, {"y" => "2"})
p eff({x: "1"}, {"x" => "3"})

k = "y"
h = {1 => "a"}.dup
h[k.to_s] = "b"
p h

s = {"x" => "1"}.dup
s[k.to_s] = "2"
s[k.to_sym] = "3"
p s
