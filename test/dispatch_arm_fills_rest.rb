# A dispatch arm calls a method whose rest or keyword rest the call
# leaves empty. The arm passes an empty Array or Hash for it.
class Tag
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def ==(other, *more)
    @name == other.name && more.empty?
  end
end

class Label
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def ==(other, **opts)
    @name == other.name && opts.empty?
  end
end

class Button
  attr_accessor :text
end

class TextField
  def text=(value, **opts)
    puts "field #{value} #{opts.size}"
  end
end

p [Tag.new("a"), Tag.new("b")].include?(Tag.new("b"))
p [Label.new("a"), Label.new("b")].index(Label.new("b"))

components = [Button.new, TextField.new, 3]
components.each do |c|
  c.text = "hi" if c.respond_to?(:text=)
end
p components[0].text
