class Hash
  def enc(out, state)
    if state[:k]
      out << "K"
    else
      out << "{"
      each { |k, v| state[:k] = true; k.enc(out, state); state[:k] = false; out << ":"; v.enc(out, state) }
      out << "}"
    end
  end
end
class String
  def enc(out, state) = out << inspect
end
class Integer
  def enc(out, state) = out << to_s
end
class Object
  def enc(out, state)
    if !state[:k] && respond_to?(:to_json)
      out << "J"
    else
      out << to_s
    end
  end
end
module Enc
  def self.encode(obj)
    out = []
    state = {}
    obj.enc(out, state)
    out.join
  end
end
p Enc.encode({"a" => 1, "b" => "s"})
p Enc.encode([1])
