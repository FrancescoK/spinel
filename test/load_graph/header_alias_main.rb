# A class header whose first segment is a constant a required file sets to
# a module (`Pay = Payments`) names a class of that module: the require
# runs first, so the constant is there when the header is read.
require_relative "header_alias_lib"
class Pay::Item
  def hi = "hi"
end
p Pay::Item.name
p Payments::Item.new.hi
