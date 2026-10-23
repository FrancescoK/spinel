# A String reader on a receiver of two classes, held ahead of the call that
# takes it, reaches a boxed parameter, a keyword Hash and NoMethodError#args
# as a String, in every String representation (#9258).
class Widget
  def initialize(label) = @label = +label
  def label = @label
end

class Gadget
  def initialize(label) = @label = +label
  def label = @label
end

class Gear; end
class Lever; end

def show(v) = v.is_a?(Integer) ? "int #{v}" : "str #{v}"
def describe(item) = "<" + show(item.label) + ">"

def opts(o) = puts(o.map { |k, v| "#{k}=#{v}" }.join(" "))
def both(item) = opts(a: item.label, b: item.label)

def attach(target, source)
  target.attach(source.label, source.label)
rescue NoMethodError => e
  puts "NoMethodError: #{e.name} #{e.args.inspect}"
end

puts show(1)
puts describe(Widget.new("gear"))
puts describe(Gadget.new("lever"))
both(Widget.new("gear"))
both(Gadget.new("lever"))
attach(Gear.new, Widget.new("gear"))
attach(Lever.new, Gadget.new("lever"))
