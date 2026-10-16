# a chain of class methods each calling super (View's into Log's, Log's
# into Base's), run on a subclass: every method of the chain runs with
# self the subclass, so each class-level @ivar it writes is the subclass's
class Base
  def self.attach_to(ns) = @ns = ns
  def self.ns = @ns
end
class Log < Base
  def self.attach_to(ns)
    r = super
    @levels = :set
    r
  end
  def self.levels = @levels
end
class View < Log
  def self.attach_to(ns) = super
end
class Sub < Log; end
View.attach_to(:v)
Sub.attach_to(:s)
p View.ns, View.levels, Sub.ns, Sub.levels, Log.ns
