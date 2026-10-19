# An ivar an --rbs seed pins to Array[String]? whose Strings another name
# shares settles in its poly form, the boxes holding the handles; a write
# of a String Array into it (here the seeded Array[String]? a class method
# answers) is wrapped element by element, the same Ruby type in its shared
# C form, and is no contradiction of the seed (#9626): the check said the
# slot was declared Array[untyped].
class SeedSharedElemsMailer
  def initialize(opts)
    @to = SeedSharedElemsMailer.addresses(opts[:to])
  end
  def to = @to
  def self.addresses(value)
    return nil if value.nil?
    list = value.is_a?(Array) ? value : [value]
    list.map { |item| item.to_s }
  end
end
s = +"a@b"
m = SeedSharedElemsMailer.new({ to: [s] })
s << ".jp"
p m.to
p SeedSharedElemsMailer.new({ to: nil }).to
p SeedSharedElemsMailer.new({ to: "c@d" }).to
