# A module included into a builtin class by reopening it is among the
# ancestors of that class's values: is_a? / kind_of? / === / case-when see
# it, for a value typed as the builtin and for a boxed one, and through a
# module the included one includes. instance_of? stays false for a module
# (activesupport's Hash includes DeepMergeable; deep_merge recurses on it).
module Inner; end
module DeepMergeable
  include Inner
  def deep_merge?(other) = other.is_a?(self.class)
end
module Formatted; end
class Hash; include DeepMergeable; end
class Array; include Formatted; end
class Numeric; include Formatted; end
class String; include Formatted; end

h = { b: 1 }
boxed = [h, 1, "s", [2], 2.5].first
p h.is_a?(DeepMergeable), h.kind_of?(DeepMergeable), DeepMergeable === h, h.is_a?(Inner)
p boxed.is_a?(DeepMergeable), Inner === boxed, h.instance_of?(DeepMergeable)
p [1].is_a?(Formatted), 3.is_a?(Formatted), 2.5.kind_of?(Formatted), "x".is_a?(Formatted), :y.is_a?(Formatted)
p 1.is_a?(DeepMergeable), [h, 1, "s", [2], 2.5].map { |v| v.is_a?(Formatted) }
r = [h, 3, :z].map do |v|
  case v
  when DeepMergeable then :merge
  when Formatted then :fmt
  else :other
  end
end
p r, Hash.include?(DeepMergeable), Hash.ancestors.take(3)
