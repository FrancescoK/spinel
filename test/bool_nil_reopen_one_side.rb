# A method only TrueClass or only FalseClass defines answers on its own
# value and raises NoMethodError on the other; a NilClass reopen's self is nil.
module Desc
  def desc = "value #{inspect}"
end
class FalseClass
  include Desc
  def no_only(n) = "f#{n}"
end
class TrueClass
  def yes_only = "t"
end
class NilClass
  include Desc
  def show = "#{to_s}|#{self.inspect}|#{nil?}"
end

p false.desc
p false.no_only(2)
p true.yes_only
p nil.desc
p nil.show
[true, false].each do |v|
  begin
    p v.yes_only
  rescue NoMethodError => e
    p e.message
  end
  begin
    p v.no_only(3)
  rescue NoMethodError => e
    p e.message
  end
end
