# A fresh String argument held before a rest gather is still text until
# the gather wraps its handle. Forwarding keeps the resulting String,
# including its frozen mark, and arguments run once in source order.
# spinel: gc-minor
def append_fresh(s) = (s << "!"; s)
def named_fresh(*r) = append_fresh(*r)
def anonymous_fresh(*) = append_fresh(*)
def all_fresh(...) = append_fresh(...)
def lead_fresh(n, *r) = named_fresh(*r)
def keyword_fresh(*r, k:) = named_fresh(*r)

p named_fresh(+"named")
p anonymous_fresh(+"anonymous")
p all_fresh(+"all")
p lead_fresh(1, +"lead")
p keyword_fresh(+"keyword", k: 1)
tail = []
p named_fresh(+"splat", *tail)
p keyword_fresh(+"both", *tail, k: 2)

class FreshParent
  def append(s) = (s << "!"; s)
end
class FreshChild < FreshParent
  def append(*) = super
end
p FreshChild.new.append(+"super")
p named_fresh(+"a\0b").bytes
begin
  named_fresh("frozen")
rescue FrozenError
  p :frozen
end

def append_keyword_fresh(s, k:) = (s << k; s)
def ordered_fresh(*r, k:) = append_keyword_fresh(*r, k: k)
def fresh_keyword
  puts "keyword"
  "?"
end
p ordered_fresh((puts "argument"; +"ordered"), k: fresh_keyword)
