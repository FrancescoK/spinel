class Hash
  def enc(out)
    out << "{"
    each { |k, v| k.enc(out); out << ":"; v.enc(out) }
    out << "}"
  end
end
class Array
  def enc(out)
    out << "["
    each { |v| v.enc(out); out << "," }
    out << "]"
  end
end
class NilClass
  def enc(out) = out << "null"
end
class TrueClass
  def enc(out) = out << "true"
end
class String
  def enc(out) = out << inspect
end
class Integer
  def enc(out) = out << to_s
end
class Float
  def enc(out) = out << to_s
end
class Object
  def enc(out) = out << "?"
end
def encode(v)
  o = []
  v.enc(o)
  o.join
end
puts encode({"a" => [1, 2.5, nil, true], "b" => {"c" => "d"}})
