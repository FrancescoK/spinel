# A class body defining methods by a string class_eval in an `each` over a
# literal list of names (activesupport's TimeWithZone forwards its Time
# readers so) defines each one, as the same loop over a constant does.
class Clock
  def initialize(h, m) = @t = [h, m]
  def hour_of = @t[0]
  def min_of = @t[1]

  %w(hour min).each do |name|
    class_eval <<-EOV, __FILE__, __LINE__ + 1
      def #{name}
        #{name}_of
      end
    EOV
  end

  %i[double].each do |name|
    class_eval "def #{name}(x) = x * 2"
  end
end
c = Clock.new(9, 30)
p c.hour, c.min, c.double(4)
