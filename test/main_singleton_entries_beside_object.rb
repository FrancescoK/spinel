# Object's `k` and main's own `k` each have two versions, and a call in a
# class's method reaches Object's and a call in a method of main's own
# reaches main's, each through a version entry. The two entries of the name
# are two C functions, so they take two names.
class A
  def run = k
end
def k = "o1"
a = A.new
def self.go = k
def self.k = "m1"
puts a.run, go
def k = "o2"
def self.k = "m2"
puts a.run, go
