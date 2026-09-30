# A program's own methods on Range, Time, File and Class -- builtins whose
# runtime type the compiler already has a C typedef for. The reopen used to
# emit a user-class struct under that same name (`struct sp_Range_s`) and
# the C compiler stopped on the collision before any call was reached.
# activesupport's blank.rb reopens Range and Time exactly like this.
class Range
  def blank? = false
  def span = last - first            # receiverless: Range#last / #first on self
  def show = puts("r#{first}..#{last}")   # receiverless puts stays Kernel#puts
end

class Time
  def blank? = false
  def stamp = "t#{year}"
end

class File
  def self.atomic?(path) = path.end_with?(".tmp")
end

class Class
  def blank? = false
end

class Foo; end

r = 1..5
p r.blank?
p r.span
p (2..3).blank?
(7..9).show
t = Time.at(0).utc
p t.blank?
p t.stamp
p File.atomic?("a.tmp")
p File.atomic?("a.rb")
p Foo.blank?
