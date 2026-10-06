# Both ends of `r, w = IO.pipe`, used inside a lambda or a block
def wake
  r, w = IO.pipe
  stop = lambda { w.write("a") }
  stop.call
  p r.readpartial(10)
end
wake

r, w = IO.pipe
[1, 2].each { |i| w.write(i.to_s) }
read = proc { r.readpartial(10) }
p read.call

def both
  r, w = IO.pipe
  f = -> { w.write("xy"); w.close; r.read }
  p f.call
  p r.eof?
end
both
