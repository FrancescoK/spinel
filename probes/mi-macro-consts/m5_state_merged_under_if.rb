module Consts
  def kind(k = nil)
    return @kind if k.nil?
    @kind = k
  end
  def constant(c) = const_set(c, public_send("calc_#{kind}_#{c.to_s.downcase}"))
end
class Agree
  extend Consts
  def self.calc_box_size = 8
  if ARGV.empty?
    kind :box
  else
    kind :box
  end
  constant :SIZE
end
p Agree::SIZE
