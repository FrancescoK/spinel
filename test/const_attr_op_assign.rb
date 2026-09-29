# `Klass.attr op= v`, `||=` and `&&=` on a class object -- a class-level
# accessor as the target -- were refused ("unsupported receiver/attr"); they
# are what Ruby defines them as, `Klass.attr = Klass.attr op v` and
# `Klass.attr || (Klass.attr = v)`, the receiver being a constant.
class Counter
  @count = 1
  @label = nil
  @flag = true
  def self.count = @count
  def self.count=(v)
    @count = v
  end
  def self.label = @label
  def self.label=(v)
    @label = v
  end
  def self.flag = @flag
  def self.flag=(v)
    @flag = v
  end
end
Counter.count += 5
Counter.count *= 2
p Counter.count
Counter.label ||= "first"
Counter.label ||= "second"
p Counter.label
Counter.flag &&= false
Counter.flag &&= true
p Counter.flag
p((Counter.count -= 2), Counter.count)
