# `undef_method :name` written in a class body with literal names undefines
# them there as `undef name` does -- known when the program is compiled
# (tzinfo's Format1::TimezoneDefiner drops a method its parent defines).
class Base
  def keep = 1
  def rules = 2
  def extra = 3
  def more = 4
end
class Narrow < Base
  undef_method :rules
  undef_method "extra", :more
end
p Narrow.new.keep, Base.new.rules, Base.new.extra
p Narrow.new.respond_to?(:rules), Narrow.new.respond_to?(:extra), Narrow.new.respond_to?(:more)
begin
  Narrow.new.rules
rescue NoMethodError
  puts "NoMethodError"
end
