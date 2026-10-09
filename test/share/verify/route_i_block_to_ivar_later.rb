class Ev
  def on(&b) = (@b = b; self)
  def emit(x) = @b.(x)
end
e = Ev.new
log = []
e.on { |x| log << x }
s = +"abc"
e.emit(s)
s << "!"
p log
