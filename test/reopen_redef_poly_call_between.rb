# B#get is defined again by a later reopening of B; the call between the two
# definitions is on a value that may be a B or a C: each class's arm reaches
# the method that class has where the call runs, B's earlier get (1), and
# the call after the later def B's later one (2). It was refused.
class B
  def get = 1
end
class C
  def get = 3
end
x = ARGV.empty? ? B.new : C.new
p x.get
class B
  def get = 2
end
p x.get
