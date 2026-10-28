# A method a required file defines and a later file redefines: a call the
# required file compiled into another method answers the version defined
# when it runs, before and after the redefinition, for an instance method
# and a top-level one.
require_relative "version_entry_lib"
m = Meter.new
puts m.show(1)
p scaled(2)
class Meter
  def unit = "km"
end
def scale = 1000
puts m.show(3)
p scaled(4)
