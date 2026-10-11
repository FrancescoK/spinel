# A class method named like one every Module has (inspect, name, include?)
# gives the call a class-side switch on a poly receiver. Any other class
# value reaching that switch answers what Module answers, not NoMethodError
# (minitest's mu_pp: `obj.inspect` on a class, beside a module of the
# program with an `inspect` of its own).
module Tagged
  def self.inspect = "#<Tagged>"
  def self.name = "TaggedName"
  def self.include?(m) = :own
end

class Plain
  include Comparable
end

class WithInspect
  def inspect = "a WithInspect"
  def name = "inst-name"
end

def show(obj) = obj.inspect
def nm(obj) = obj.name
def inc(obj) = obj.include?(Comparable)

[Tagged, Plain, Comparable, String, WithInspect.new, [1, Plain], "s", 1, nil].each do |v|
  puts show(v)
end
[Tagged, Plain, Comparable, WithInspect.new].each { |v| puts nm(v) }
[Tagged, Plain, String, Kernel].each { |v| p inc(v) }

# a method Module does not have still raises for a class that lacks it
module Applied
  def self.apply = "applied"
end
def run(obj) = obj.apply
[Applied, Plain].each do |v|
  begin
    puts run(v)
  rescue NoMethodError => e
    puts e.class
  end
end
