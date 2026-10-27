# Object's `k` has two versions and main has singleton versions of its own.
# A call in a class's method reaches Object's version defined when it runs;
# a call at the top level reaches main's. The version entry of Object's `k`
# is not a top-level def of the program, so its dispatch calls are no
# receiverless call the plan refuses.
class A
  def run = k
end
def k = "o1"
a = A.new
puts a.run
def k = "o2"
puts a.run
def self.k = "m1"
puts k
def self.k = "m2"
puts k
puts a.run
