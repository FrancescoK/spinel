# A class method no reopening of a builtin class defines -- activesupport's
# `::Time.zone` in DateAndTime::Zones and DateTime.current, reached without
# active_support/time loaded -- is the program's NoMethodError, raised when
# the call runs: a builtin class has a closed method table, so nothing else
# could answer it. It used to refuse the build once Time was reopened at all
# (the closed-table rule looked only at classes with no entry of their own),
# so a default that mentions it, never taken, sank the whole program.

class Time
  def acts_like_time? = true
end

def stamp(t, zone = ::Time.zone)
  "#{t.to_i} in #{zone}"
end
puts stamp(Time.at(0).utc, "UTC")

begin
  Time.zone
rescue NoMethodError => e
  puts e.message
end
begin
  p Time.find_zone!("x")
rescue NoMethodError => e
  puts e.message
end
p Time.at(0).utc.acts_like_time?

# as a condition, DateTime.current's shape
class DateTime2
  def self.current = ::Time.zone ? ::Time.zone.now.to_i : ::Time.now.to_i
end
begin
  DateTime2.current
rescue NoMethodError => e
  puts e.message
end
