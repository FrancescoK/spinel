# `singleton_class.prepend(Mod)` / `singleton_class.include(Mod)` as a
# statement of a class or module body adds Mod's methods to the class object
# -- what `extend Mod` does, the precedence between Mod and the class's own
# singleton methods aside. activesupport's core_ext/enumerable.rb prepends a
# const_missing hook onto Enumerable's singleton this way; the hook is never
# consulted by a static constant lookup, and the rest of the body compiles.

module Hooks
  def tag = "hooked #{name}"
  private
    def const_missing(name)
      name == :Ghost ? "ghost" : super
    end
end

module Host
  singleton_class.prepend(Hooks)
  def self.hello = "hello"
end

class Widget
  singleton_class.include(Hooks)
  def self.make = "made"
end

p Host.hello, Host.tag
p Widget.make, Widget.tag
