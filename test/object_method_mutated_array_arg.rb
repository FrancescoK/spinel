class Hash
  def enc(out)
    out << "{"
    each { |k, v| v.enc(out) }
    out << "}"
  end
end
class Object
  def enc(out) = out << "?"
end
o = []
{"a" => 1}.enc(o)
p o
