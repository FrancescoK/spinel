# A String that is the shared handle (an alias mutates it) and is frozen
# later keeps its frozen mark through a read of it: `to_s`, `itself`,
# `then`, `inject`, a Hash key, a reader and an implicit-self reader answer
# a frozen String, so `<<` on the read raises FrozenError, as CRuby's
# answer is the String itself. An unfrozen one reads unfrozen.
s = +"q"
t = s
t << "!"
s.freeze
p s.to_s.frozen?, s.itself.frozen?, s.then { |x| x }.frozen?, [1].inject(s) { |m, _| m }.frozen?
h = { s => 1 }
p h.keys.first.frozen?
a = s.to_s
p((a << "z" rescue $!.class))
p((s.itself << "z" rescue $!.class))
class B
  attr_reader :buf
  def initialize = (@buf = +"b")
  def go
    r = @buf
    r << "!"
    @buf.freeze
    [@buf.to_s.frozen?, @buf.itself.frozen?, buf.to_s.frozen?, buf.frozen?]
  end
end
p B.new.go
x = +"x"
y = x
y << "2"
p x.to_s.frozen?, x.itself.frozen?
