# A class method or an instance method named sub types a boxed String's
# .sub chain poly; the String answer of each sub is boxed for that slot.
module Gadget
  def self.sub(a, b) = a
end

class Widget
  def gsub(a, b) = b
end

p ["widget", 1].first.strip.sub(/a/, "").sub(/b/, "")
p ["gadget", 2].first.strip.gsub(/g/, "G").gsub(/d/, "D")
p Gadget.sub(1, 2)
p Widget.new.gsub(1, 2)
