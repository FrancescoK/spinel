# A class named after a builtin module (Warning, Comparable, Math, Kernel)
# inside another namespace is a class of its own, beside the builtin.
module Reports
  class Warning < StandardError
    def tag = :report
  end
  class Math
    def self.twice(x) = x * 2
  end
end
module Text; end
class Text::Comparable
  def initialize(v) = @v = v
  def v = @v
end

begin
  raise Reports::Warning, "low disk"
rescue Reports::Warning => e
  p e.message, e.class, e.tag
end
p Reports::Math.twice(4), Math.sqrt(16)
p Text::Comparable.new(3).v, Comparable.class
