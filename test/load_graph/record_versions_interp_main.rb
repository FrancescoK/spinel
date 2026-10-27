# A method defined twice in a program with an interpolated String: the
# record's dump (record_versions_interp_main.rb.load-record) lists the
# method's versions after scanning the program's Strings for its name.
class Gauge
  def level = 1
end
class Gauge
  def level = 2
end
p "#{Gauge.new.level}x"
