# A module included at the top level and in a class that defines puts: a
# receiverless puts in the module's method is Kernel#puts for main, which asks
# its argument for to_s
module Helpers
  def show(x) = puts(x)
end
include Helpers
class Foo
  include Helpers
  def puts(x) = Kernel.puts("Foo puts")
end
class Pt
  def to_s = "Pt to_s"
end
show(Pt.new)
Foo.new.show(2)
