# A dispatch arm calls a method with a required keyword that the call
# does not give. The arm raises ArgumentError, as CRuby does.
class Tag
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def ==(other, strict:)
    strict ? equal?(other) : @name == other.name
  end
end

class Money
  attr_reader :cents

  def initialize(cents)
    @cents = cents
  end

  def +(other, round:)
    Money.new(@cents + other.cents)
  end
end

class Button
  attr_accessor :text
end

class Banner
  def text=(value, color:)
    puts "banner #{value} #{color}"
  end
end

begin
  p [Tag.new("a"), Tag.new("b")].include?(Tag.new("b"))
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end

items = [Money.new(100), "note", 3]
begin
  p (items[0] + Money.new(5)).cents
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end

[Button.new, Banner.new].each do |c|
  c.text = "hi"
  puts "set #{c.class}"
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end
