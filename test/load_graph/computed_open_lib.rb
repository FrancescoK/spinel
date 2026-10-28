class OpenMoney
  def initialize(c) = @c = c
  def +(o) = OpenMoney.new(@c + o)
  def cents = @c
end
puts "computed_open_lib"
