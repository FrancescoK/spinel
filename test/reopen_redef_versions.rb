# a class reopened at the top level with an instance method defined again:
# the calls the program body makes between the two definitions reach the
# earlier one, as in CRuby, and the calls after it the later one

class B
  def get(x) = x + 1
  def twice(x) = get(get(x))
end

class S < B
end

class Other
  def get(x) = x * 10
end

b = B.new
p b.get(1)
p S.new.get(1)
p Other.new.get(1)
[1, 2].each { |i| p b.get(i) }

class B
  def get(x) = x + 100
end

p b.get(1)
p S.new.get(1)
p Other.new.get(1)

# a method defined once is the same before and after
class B
  def name = "b"
end
p b.name
