# A `+` chain whose receiver is a call of a method its class lacks (the
# NoMethodError raise, typed as nothing) and whose last operand is a String
# subclass instance: the chain is typed as that instance while it runs
# boxed, and the local it was assigned to took the box raw, so the C did not
# build. The raise runs where the chain would, and the local keeps its type.
class SafeBuffer < String
end

class TagBuilder
  def tag(name)
    SafeBuffer.new("<#{name}>")
  end
end

class Renderer
  def initialize
    @tb = TagBuilder.new
  end

  def tag_builder
    @tb
  end

  def render(content, label)
    option_tags = SafeBuffer.new("<option>x</option>")
    if label
      option_tags = tag_builder.option(content, value: "", label: label) + "\n" + option_tags
    end
    option_tags
  end
end

r = Renderer.new
puts r.render("a", nil)
begin
  puts r.render("a", "b")
rescue NoMethodError => e
  puts e.message
end
