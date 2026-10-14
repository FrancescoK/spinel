# A bare `super` from `def m(key, ...)` in a Hash or Array subclass
# (faraday's Utils::Headers#fetch): the builtin gets the leading parameter
# as the method left it and whatever `...` carried, the block included --
# fetch(k), fetch(k, default) and fetch(k) { } each as CRuby answers.

class Headers < ::Hash
  def fetch(key, ...)
    key = key.to_s.downcase
    super
  end
end

h = Headers.new
h["content-type"] = "json"
p h.fetch("Content-Type")
p h.fetch("X-Missing", "dflt")
p h.fetch("X-Missing") { |k| "blk #{k}" }
begin
  h.fetch("Nope")
rescue KeyError => e
  p e.message
end

class List < Array
  def fetch(i, ...)
    i = i.to_i
    super
  end
end

l = List.new([10, 20])
p l.fetch("1")
p l.fetch(5, :none)
p l.fetch(9) { |i| i * 2 }
