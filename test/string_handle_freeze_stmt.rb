# `x.freeze` as a statement freezes the String even when x reads back as an
# expression rather than a plain C name: a parameter the caller lends by
# reference (a method's, a keyword's, a yielded block's) or an ivar that
# holds the shared handle (#6179). The statement emitted `(void)(x)`, so
# frozen? said false and the next append went through; the value form
# (`y = x.freeze`) already froze it.

def app(x)
  x.freeze
  p x.frozen?
  x << "!"
end

def kw(x:)
  x.freeze
  p x.frozen?
  x << "!"
end

def mid(y) = app(y)

def yy(v) = yield(v)

def try
  yield
rescue FrozenError => e
  puts "FrozenError: #{e.message}"
end

s = +"ab"
try { app(s) }
p s

k = +"kw"
try { kw(x: k) }
p k

m = +"mid"
try { mid(m) }
p m

t = +"blk"
try { yy(t) { |b| b << "?"; b.freeze; p b.frozen?; b << "!" } }
p t

# the ivar holds the shared handle: the reader hands it to a local that
# appends, and the freeze has to reach the handle, not a copy of its text
class Holder
  def initialize; @s = +"iv"; end
  def run
    t = @s; t << "?"
    @s.freeze
    p @s.frozen?
    p t.frozen?
    @s << "!"
  end
  def show = @s
end
h = Holder.new
try { h.run }
p h.show

# a frozen String is cloned frozen and dup'ed unfrozen
def copies(x)
  x << "?"
  x.freeze
  p x.clone.frozen?
  p x.dup.frozen?
end
c = +"cp"
copies(c)
p c
