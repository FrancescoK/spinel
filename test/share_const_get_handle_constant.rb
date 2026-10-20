# A String constant that a mutated String's share class takes in is held as
# the shared handle. A const_get by a name computed at run time dispatches
# over the program's constants, and one with a literal name reads the
# constant directly; both answer the constant's String, as a read of the
# constant does.
TAG = 'Tag'
LABEL_MSG = 'label'
class Rec
  attr_reader :name
  def initialize(n) = @name = n
end
class Box
  def message(kind) = self.class.const_get(:"#{kind}_MSG")
end
m = +"mut"
a = Rec.new(ARGV.size > 3 ? TAG : m)
b = Rec.new(TAG)
held = [a.name, b.name]
m << "!"
p held[0], a.name.equal?(m), b.name.equal?(TAG)
p Box.new.message("LABEL"), Object.const_get(:"TA#{"G"}"), Object.const_get(:TAG).size
p Object.const_defined?(:"TA#{"G"}"), Object.const_get(:"TA#{"G"}").equal?(TAG)
