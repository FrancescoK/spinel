# An empty **h adds no positional argument when the receiver may be a Proc,
# a Method, a native object or a class; a non-empty one still passes the hash.
require "stringio"

class Caller
  def call(*a, **kw) = [:user, a, kw]
end

class Sink
  def initialize = @out = []
  def puts(*a, **kw) = @out << [a, kw]
  def seek(*a, **kw) = [:sink, a, kw]
  def out = @out
end

def one(x) = [:one, x]
def two(x, y) = [:two, x, y]

def run(r, h)
  r.call(1, **h)
rescue ArgumentError => e
  [:arg_error, e.message]
end

def run0(r, h)
  r.call(**h)
end

e = {}
f = {a: 1}
[proc { |x, y| [x, y] }, ->(*a) { a }, ->(x) { [:lam, x] }, method(:one), method(:two), Caller.new].each do |r|
  p run(r, e)
end
[proc { |x, y| [x, y] }, ->(*a) { a }, method(:two), Caller.new].each do |r|
  p run(r, f)
end
[proc { |*a| a }, -> { :none }, Caller.new].each do |r|
  p run0(r, e)
end
p run0(proc { |*a| a }, f)

def emit(io, h)
  io.puts("x", **h)
end

def sk(io, h)
  io.seek(2, **h)
end

s = StringIO.new
emit(s, e)
emit(s, f)
p s.string
k = Sink.new
emit(k, e)
emit(k, f)
p k.out
s = StringIO.new("hello")
p sk(s, e)
p s.read
p sk(k, e)
p sk(k, f)

def conv(k, h)
  k.try_convert(**h)
rescue ArgumentError => e
  [:arg_error, e.message]
rescue NoMethodError
  :no_method
end

p conv([Array, 0][0], e)
p conv([Array, 0][0], f)
p conv([Hash, 0][0], f)
p conv([Object, 0][0], e)
