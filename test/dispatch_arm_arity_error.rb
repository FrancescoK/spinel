# A dispatch arm calls a method that needs more arguments than the
# call gives. The arm raises ArgumentError, as CRuby does.
class Vector
  attr_reader :x

  def initialize(x)
    @x = x
  end

  def ==(other, precision)
    @x.round(precision) == other.x.round(precision)
  end
end

class Button
  attr_accessor :text
end

class Banner
  def text=(value, color)
    puts "banner #{value} #{color}"
  end
end

class Ticker
  define_method(:text=) { |value, speed| puts "ticker #{value} #{speed}" }
end

a = Vector.new(1.0)
b = Vector.new(1.0)
p a.==(b, 2)
begin
  p [a].include?(b)
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end

[Button.new, Banner.new, Ticker.new].each do |c|
  c.text = "hi"
  puts "set #{c.class}"
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end
