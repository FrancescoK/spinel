# Mixins and superclasses through an autoloaded constant's path: the path's
# head runs its file where the class body or header reads it, and the
# mixed-in methods and constants answer afterwards.
autoload :MixPath, File.join(__dir__, "autoload_mixin_path_lib")
autoload :MixPathBase, File.join(__dir__, "autoload_mixin_path_base_lib")
puts "main"
class Holder
  include MixPath::Inner::Inc
  extend MixPath::Inner::Ext
  def pre = "holder pre"
  prepend MixPath::Inner::Pre
  Y = X + 1
  def self.both = [X, Y]
end
p Holder.new.inc, Holder.ext, Holder.new.pre, Holder.both, Holder::X
class Sent; end
Sent.include(MixPath::Inner::Inc)
Sent.extend(MixPath::Inner::Ext)
p Sent.new.inc, Sent.ext
class Sub < MixPath::Base
  def own = "own"
end
p Sub.make.own, Sub.new.base, Sub.superclass
class Sub2 < MixPathBase
end
p Sub2.new.base2, Sub2.superclass
