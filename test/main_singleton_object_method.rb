# A top-level `def self.k` is main's singleton method and a top-level `def k`
# Object's private method, in either order. A call on main -- receiverless
# or `self.k`, in the top-level statements, their blocks and main's
# singleton bodies -- finds the singleton first, as CRuby's lookup does;
# from any other object `k` is Object's. A name `k__main1` of the program's
# own stays apart from the singleton's.
def k = 1
p k
def self.k = 2
p k
p self.k
[1].each { p k }
class A
  def t = k
end
p A.new.t

def self.both = [k, self.k]
p both

def self.j = 20
def j = 10
p j
p Object.new.send(:j)

def self.r(n) = n <= 0 ? 0 : 1 + r(n - 1)
p r(4)

def k__main1 = :taken
p k__main1

class << self
  def h = 30
end
def h = 40
p h
p A.new.instance_eval { h }
