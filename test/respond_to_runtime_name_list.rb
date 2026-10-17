# respond_to? with a name only known at run time (a String or a Symbol)
# answers from each class's list of names: its own methods, inherited
# ones, readers and writers, aliases, private ones only with include_all,
# and the top-level methods every object has privately.
def helper = 1

class Base
  attr_reader :r
  attr_writer :w
  def base_m = 1
  alias base_alias base_m
  private def secret = 2
end

class Child < Base
  include Comparable
  def <=>(o) = 0
  def child_m = 3
end

class Lone
  def lone_m = 4
end

names = [:base_m, "base_alias", :r, "w=", :secret, "child_m", :between?, "lone_m", :helper, "nope"]
[Base.new, Child.new, Lone.new, 1, "s"].each do |o|
  names.each { |m| puts "#{o.class} #{m.inspect} #{o.respond_to?(m)} #{o.respond_to?(m, true)}" }
end
