# Methods added to Hash, Time and Range are called on their values.
class Hash
  def two = self.size * 2
  def my_keys
    out = []
    self.each { |k, _v| out << k }
    out
  end
end
class Time
  def yr = self.year
end
class Range
  def span = self.last - self.first
end
p({a: 1}.two)
p({"x" => 1, "y" => 2}.my_keys)
p Time.at(0).utc.yr
p (3..10).span
begin
  1.two
rescue NoMethodError
  p :no_method
end
