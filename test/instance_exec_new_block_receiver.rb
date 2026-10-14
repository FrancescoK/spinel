class Holder
  def initialize(&b) = @b = b
  def run(o) = o.instance_exec(&@b)
end

class Sub < Holder
end

module Ns
  class Kept
    def self.new(&b) = Holder.new(&b)
  end
end

class Other
  def initialize
    @v = yield
  end
  attr_reader :v
end

def helper = :top

p Holder.new { self.class }.run(Object.new)
p Sub.new { self.class }.run("s")
p Ns::Kept.new { self.class }.run(1)
p Other.new { self.helper }.v
p Other.new { self.to_s }.v
p Other.new { self }.v.inspect
