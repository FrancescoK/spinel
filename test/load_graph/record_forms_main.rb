# The definition forms that run code of the program's (--dump-load-record,
# record_forms_main.rb.load-record): a form whose own name the program
# defines where the call finds it, or one that fires a hook the program
# defines on the class receiving it (method_added for attr_accessor and
# define_method, also from a superclass; included for include, on the
# module). The forms of a class with no such method run none.
module Hooked
  def self.included(base) = nil
  def hi = "hi"
end
module Plain
  def ho = "ho"
end
class Watched
  def self.method_added(name) = nil
end
class Sub < Watched
  define_method(:dm) { "dm" }
end
class Quiet
  attr_accessor :a
  include Plain
  include Hooked
end
class Watched
  attr_reader :r
end
class Own
  def self.attr_writer(*names) = nil
  attr_writer :w
  attr_reader :v
end
q = Quiet.new
q.a = 1
puts q.a, q.hi, q.ho, Sub.new.dm
