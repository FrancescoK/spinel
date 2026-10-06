# A dispatch arm calls a method with an optional parameter before the
# required one. The one argument binds to the required parameter.
class Tag
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def ==(strict = false, other)
    strict ? equal?(other) : @name == other.name
  end
end

class Button
  attr_accessor :text
end

class Field
  def text=(prefix = ">", value)
    puts "field #{prefix}#{value}"
  end
end

p [Tag.new("a"), Tag.new("b")].include?(Tag.new("b"))
[Button.new, Field.new].each { |c| c.text = "hi" }
