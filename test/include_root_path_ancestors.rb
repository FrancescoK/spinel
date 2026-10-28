# `include ::Helper` inside a module that has a Helper of its own includes
# the top-level Helper, and a bare `include Helper` there the module's own:
# ancestors, include?, is_a? and `when` name the one included
module Helper
  def help = "top"
end
module Outer
  module Helper
    def help = "outer"
  end
  class Inside
    include ::Helper
  end
  class Near
    include Helper
  end
end
p Outer::Inside.new.help
p Outer::Inside.ancestors.take(3)
p Outer::Inside.include?(Outer::Helper), Outer::Inside.include?(::Helper)
p Outer::Inside.new.is_a?(Outer::Helper)
i = Outer::Inside.new
n = Outer::Near.new
p i.is_a?(::Helper), n.is_a?(Outer::Helper), n.is_a?(::Helper)
x = [i, n, 1][0]
y = [i, n, 1][1]
p x.is_a?(Outer::Helper), x.is_a?(::Helper), y.is_a?(Outer::Helper), y.is_a?(::Helper)
p(case i when Outer::Helper then :outer when ::Helper then :top else :none end)
p(case n when ::Helper then :top when Outer::Helper then :outer else :none end)
p(case x when Outer::Helper then :outer when ::Helper then :top else :none end)
p(case y when ::Helper then :top when Outer::Helper then :outer else :none end)
p(i.is_a?(Outer::Helper) ? 1 : 2, n.is_a?(::Helper) ? 1 : 2)
