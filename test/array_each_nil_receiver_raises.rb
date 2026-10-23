# each over an Array an instance variable holds before it is set raises
# NoMethodError on the nil, as CRuby does, where the walk read the missing
# Array as an empty one.
class L
  def add(s) = @rows << s
  def init = @rows = []
  def bang = @rows.each { |x| p x + 1 }
  def names = @names.each { |x| puts x }
  def set_names = @names = ["a"]
end
l = L.new
begin
  l.bang
rescue NoMethodError => e
  puts e.message
end
begin
  l.names
rescue NoMethodError => e
  puts e.message
end
l.init
l.add(1)
l.bang
l.set_names
l.names
