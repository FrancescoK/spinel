# A class held in a variable that may be a class with a class method name
# (or to_s / inspect) of its own, or one without: the one with it answers by
# its method, the others by Module#name. Every value answered Module#name,
# whatever the class defined.

module Store
  def self.name = "store!"
  def self.to_s = "Store as text"
end

class Plain
end

class Base
  def self.inspect = "#<Base family>"
end

class Child < Base
end

anon = Class.new

picks = ARGV.empty? ? [Store, Plain, Base, Child, anon] : [Plain]
picks.each do |k|
  p k.name
end

k = ARGV.empty? ? Plain : Store
n = k.name
p n, n.frozen?
k = ARGV.empty? ? Store : Plain
p k.name, k.to_s
k = ARGV.empty? ? Child : Plain
p k.inspect, k.name
k = ARGV.empty? ? anon : Store
p k.name
