# A program's own define_method is an ordinary method, so a computed name is
# not a class-building call.
class InstanceRegistry
  def define_method(name, &blk) = [name, blk.call]
  def run(name) = define_method(name) { 1 }
end
p InstanceRegistry.new.run(:a)
