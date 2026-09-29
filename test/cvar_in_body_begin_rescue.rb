# A class variable written inside begin/rescue (or if) in a module body is
# declared on the module; only the body's direct statements declared one, and
# the class method reading it referenced an undeclared C global.
module Vips
  begin
    x = Integer("12")
    @@is_unified = x > 10
  rescue ArgumentError
    @@is_unified = false
  end
  if true
    @@mode = :fast
  end
  def self.unified? = @@is_unified
  def self.mode = @@mode
end
p Vips.unified?, Vips.mode
