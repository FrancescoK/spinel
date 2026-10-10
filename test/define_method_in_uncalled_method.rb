# A define_method in a method's body defines its method only when that method
# runs. A class method nothing calls replaces nothing: calls keep reaching the
# method that is defined (and here the replacement's body would call a method
# no class defines).
module Pretty
  def show(x) = x.inspect
end

class Report
  include Pretty

  def self.make_pretty!
    define_method :show, &:pretty_inspect
  end

  def self.add_shout!
    define_method(:shout) { |s| s.upcase }
  end

  def line = "got #{show([1, "a"])}"
end

puts Report.new.line

# a method that is called still defines what it names
Report.add_shout!
puts Report.new.shout("hi")
