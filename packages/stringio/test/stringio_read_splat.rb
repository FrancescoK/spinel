require "stringio"

# read(*args) on a StringIO, typed or boxed, as an input wrapper forwards it
class Wrap
  def initialize(input) = @input = input
  def read(*args) = @input.read(*args)
  def write(*args) = @input.write(*args)
  def string = @input.string
end
Wrap.new(1)
p Wrap.new(StringIO.new("hello")).read
p Wrap.new(StringIO.new("hello")).read(nil)
w = Wrap.new(StringIO.new("hello"))
p w.read(2), w.read(10), w.read(1), w.read
p Wrap.new(StringIO.new("hello")).read(0)

def fwd(io, *args) = io.read(*args)
p fwd(StringIO.new("abc")), fwd(StringIO.new("abc"), 1)

begin
  Wrap.new(StringIO.new("x")).read(-1)
rescue ArgumentError => e
  p e.message
end
begin
  Wrap.new(StringIO.new("x")).read("2")
rescue TypeError => e
  p e.message
end
begin
  Wrap.new(StringIO.new("x")).read(1, +"", 3)
rescue ArgumentError => e
  p e.message
end

out = Wrap.new(StringIO.new)
p out.write("a", 1, :b), out.string
