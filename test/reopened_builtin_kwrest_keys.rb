# Keyword-rest parameters of builtin reopenings accept every Ruby Hash key.
# spinel: gc-minor
class Random
  def take(a, **kw) = [a, kw]
  def options(a, known: 7, **kw) = [a, known, kw]
end
class Array
  def take(a, **kw) = [a, kw]
  def options(a, known: 7, **kw) = [a, known, kw]
end
def take(a, **kw) = [a, kw]

r = Random.new(1)
a = [8]
p r.take(1, **{ "s" => 2 })
p a.take(1, **{ "s" => 2 })
p take(1, **{ "s" => 2 })
kw = { "s" => [3, 4], :sym => 5, 6 => :integer_key }
p r.take(2, **kw)
p a.take(2, **kw)
p r.take(3, before: 1, **{ "s" => 2 }, after: 3)
p a.take(3, **{ "s" => 1 }, **{ "s" => 2, :sym => 3 })
p r.options(4, **{ known: 9, "known" => 10, "extra" => [11] })
p a.options(4, **{ "known" => 10, "extra" => [11] })
p r.take(5), a.take(5)
p r.take(6, **{}), a.take(6, **{})
p r.take(7, only: :symbol), a.take(7, only: :symbol)

# A supplied but unused block does not alter keyword binding.
p r.take(8, **{ "literal" => 1 }) { :unused }
p a.take(8, **{ "literal" => 1 }) { :unused }
blk = proc { :unused }
p r.take(9, **{ "proc" => 2 }, &blk)
p a.take(9, **{ "proc" => 2 }, &blk)

# Named and anonymous keyword forwarding carry the same non-Symbol keys.
def named_keys(a, **kw) = a.take(10, **kw)
def array_keys(a, **) = a.take(11, **)
p named_keys(a, **{ "forwarded" => 12 })
p array_keys(a, **{ "forwarded" => 13 })
p kw

# A String local written in the receiver and appended to later is a String
# buffer; its call still reaches the String reopening.
class String
  def pair(a, **kw) = [a, kw]
end
def key_hash(k) = { k => 1 }
buf = +"b"
p((buf = +"c").pair(key_hash("arg"), **key_hash("kw")))
3.times { |i| buf << i.to_s }
p buf
