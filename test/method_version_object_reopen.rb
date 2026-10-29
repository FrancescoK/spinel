# A method a reopening of Object or Kernel defines twice is reached by
# whatever receiver's lookup ends in Object: a call answers the version
# defined when it runs, on a class (by constant, held in a local, a
# subclass, a module), on self in a class method or an instance method, and
# on an instance, at a load point and inside a method run before and after
# the redefinition.
class Object; def on_const = 1; end
module Kernel; def on_kernel = :k1; end
class Object; def in_local = 1; end
class Object; def on_sub = 1; end
class Object; def from_cmethod = 1; end
class Object; def from_method = 1; end
class Object; def from_module = 1; end
class Object; def from_imethod = 1; end
class Object; def on_instance = 1; end

class U
  def self.bare = from_cmethod
  def self.on_self = self.from_cmethod
  def run = from_imethod
end
class V < U; end
module M
  def self.bare = from_module
end
def via_const = U.from_method
def via_instance(o) = o.on_instance

k = U
u = U.new
p U.on_const, U.on_kernel, k.in_local, V.on_sub
p U.bare, U.on_self, via_const, M.bare, M.from_module, u.run, via_instance(u)

class Object; def on_const = 2; end
module Kernel; def on_kernel = :k2; end
class Object; def in_local = 2; end
class Object; def on_sub = 2; end
class Object; def from_cmethod = 2; end
class Object; def from_method = 2; end
class Object; def from_module = 2; end
class Object; def from_imethod = 2; end
class Object; def on_instance = 2; end

p U.on_const, U.on_kernel, k.in_local, V.on_sub
p U.bare, U.on_self, via_const, M.bare, M.from_module, u.run, via_instance(u)
