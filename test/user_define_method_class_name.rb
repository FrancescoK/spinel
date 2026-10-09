# A class method named define_method is the program's own as well.
class ClassRegistry
  def self.define_method(name, &blk) = [name, blk.call]
  def self.run(name) = define_method(name) { 3 }
end
p ClassRegistry.run(:q)
