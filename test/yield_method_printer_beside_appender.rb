# A yield whose block is a Method of one of Kernel's printers (`&method(:p)`,
# `&method(:puts)`) hands its Strings to a target that neither changes nor
# keeps them. It was counted as an unknown target, and any appending lambda
# elsewhere in the program then refused the yield (#9207).
class Widget
  def initialize
    @h = { "a" => "x", "b" => "y" }
  end

  def each_pair
    @h.each { |k, v| yield k, v }
    self
  end

  def each_value
    @h.each_value { |v| yield v }
  end
end

Widget.new.each_pair(&method(:p))
Widget.new.each_value(&method(:puts))

shout = ->(s) { s << "!" }
t = +"hi"
shout.call(t)
puts t
