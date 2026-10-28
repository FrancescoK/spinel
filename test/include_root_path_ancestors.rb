# `include ::Helper` inside a module that has a Helper of its own includes
# the top-level Helper: ancestors, include? and is_a? name that one
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
end
p Outer::Inside.new.help
p Outer::Inside.ancestors.take(3)
p Outer::Inside.include?(Outer::Helper), Outer::Inside.include?(::Helper)
p Outer::Inside.new.is_a?(Outer::Helper)
