# `CONST[i] = s` on an Array constant is the Array's own store: it reaches
# no user-defined `[]=`, so a shared String handed to it does not make
# another class's `[]=` parameter a shared handle (#8564). Widget's @label
# takes a plain String from a Hash and keeps its own type.
LAST = [""]

class Holder
  def initialize(s)
    @s = s
  end

  def bang
    @s << "!"
  end
end

def remember(s)
  Holder.new(s).bang
  LAST[0] = s
end

class Widget
  def []=(key, value)
    @label = value
  end

  def label
    @label
  end
end

name = +"Ada"
remember(name)
p LAST[0]

w = Widget.new
{ "label" => "plain" }.each { |k, v| w[k] = v }
p w.label

# a String constant's own `[]=` is the String's too
TITLE = +"abc"
TITLE[0] = "x"
p TITLE
