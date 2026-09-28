# A computed send name reaches what the receiver's runtime class answers:
# `self` in a base-class method may be a subclass instance, so a hook only
# the subclass defines is dispatched, and an alias is a name it answers too.

class Base
  def dispatch(ev) = send("on_#{ev}")
  def on_load = :base_load
end

class Button < Base
  def on_click = :clicked
  alias on_tap on_click
end

class Link < Base
  def on_hover = :hovered
  def orig = :orig
  alias_method :am, :orig
end

p Button.new.dispatch("click")
p Button.new.dispatch("tap")
p Link.new.dispatch("hover")
p Link.new.dispatch("load")
p Link.new.send("a" + "m")

[Base.new, Link.new].each do |o|
  o.dispatch("click")
rescue NoMethodError => e
  p e.name
end
