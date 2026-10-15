# A multiple assignment into an Integer or Float ivar that can hold nil, the
# same ivar read in the call on the right: at top level and in a class
# method the ivar is a static whose type carries its own nil; in an instance
# method it is a field with a nil bit (#9289).
def helper(a, b)
  [a.to_f, b]
end
@interval = 1.0
@interval, result = helper(@interval, 3)
puts "interval=#{@interval} result=#{result}"
@interval, result = [nil, 4]
p @interval, result

class Knob
  def self.set(v)
    @level = 2
    @level, @n = [v, @level]
    [@level, @n]
  end

  def initialize = (@pos = 0.5)

  def move(v)
    @pos, rest = [v, @pos]
    [@pos, rest]
  end
end
p Knob.set(nil), Knob.set(7)
k = Knob.new
p k.move(nil), k.move(2.5)
