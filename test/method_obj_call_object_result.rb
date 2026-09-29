# The object a Method's call answers, read from directly: `m.call(5).v`.

class R
  def initialize(a) = @v = a
  attr_reader :v

  def self.mk(x) = new(x)
  def me = self
  def peer(o) = o
end

class V
  def initialize(a) = @v = a
  attr_reader :v

  def self.mk(x) = new(x)
end

p R.method(:mk).call(5).v
p R.new(6).method(:me).call.v
p R.new(7).method(:peer).call(R.new(8)).v
m = R.method(:mk)
p m.call(9).me.v
p V.method(:mk).call(10).v
