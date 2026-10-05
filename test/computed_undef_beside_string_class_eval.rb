# A Module method that undefines a method named by a value changes the
# instance methods of the module it is called on (activesupport's
# remove_possible_method) -- never the class_eval a class body calls, which
# is Module's own. A class body's string class_eval still defines into it.
class Module
  def drop_if_defined(method)
    undef_method(method) if method_defined?(method)
  end
end

class Conf
  class_eval "def self.level = 3", __FILE__, __LINE__
  class_eval <<~RUBY, __FILE__, __LINE__ + 1
    def name_of = "conf"
  RUBY
  def gone = 1
  drop_if_defined :gone
end

p Conf.level, Conf.new.name_of
