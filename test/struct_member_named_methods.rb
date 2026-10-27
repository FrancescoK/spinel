# A Struct member named `methods` is the instances' reader of it, as any
# member is, not Object#methods; also where the program defines a method
# under a run-time condition, whose reflection lists are refused (#10345).
Decl = Struct.new(:name, :methods)

class Helper
  def base = "base"
  if ARGV.empty?
    def extra = "extra"
  end
end

class Box
  attr_reader :methods
  def initialize(m) = @methods = m
end

d = Decl.new("T", ["a", "b"])
d.methods.each { |m| puts m }
p d.methods
d.methods = ["c"]
p d.methods.size
p Box.new([1, 2]).methods
puts Helper.new.base
