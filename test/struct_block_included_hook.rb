# statements in a Struct.new block run when the block does, and an `include`
# there runs the module's `included` hook
module M
  module ClassMethods
    def build = new(7)
  end
  def self.included(base)
    puts "included"
    base.extend(ClassMethods)
  end
  def hi = "hi #{a}"
end
S = Struct.new(:a) do
  puts "block runs"
  include M
  def twice = a * 2
end
p S.build.hi
p S.new(4).twice
