# This observable String copy is refused: thread target ivar.
@s = "lit"
@s, = [String.new("a")]
Thread.new(@s) { |q| q << "#" }.join
puts @s
