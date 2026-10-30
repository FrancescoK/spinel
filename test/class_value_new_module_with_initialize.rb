# `new` on a value that holds a Class arms every class that has a constructor,
# not a module: a module that defines `initialize` for a class to include has
# none (a Class value cannot be one), and the arm for the module was a call of
# a constructor nobody wrote.
module WithResponse
  def initialize(msg, res = nil)
    super(msg)
    @response = res
  end

  attr_reader :response
end

class HttpErr < StandardError
  include WithResponse
end

def error_type = HttpErr

begin
  raise error_type.new("404", :r)
rescue HttpErr => e
  p [e.message, e.response]
end

module Helper
  def initialize(a)
    @a = a
  end
end

class Widget
  include Helper
  attr_reader :a
end

def kind = Widget
p kind.new(5).a

# the same arms for `raise` of a value that may be a Class and for the
# subclasses a class method's bare `new` picks by receiver: none names a
# class no object of may exist
class OptionError < StandardError
  def initialize(opt, extra = nil)
    super("bad #{opt}")
    @extra = extra
  end
end

class MissingOption < OptionError; end
class BadOption < OptionError; end
class UnusedOption < OptionError; end

def error_class(missing) = missing ? MissingOption : BadOption

begin
  raise error_class(true).new("-x")
rescue OptionError => e
  p [e.class, e.message]
end

class Shape
  def self.build(*args) = new(*args)
  def initialize(n = 0) = (@n = n)
  attr_reader :n
end

class Square < Shape; end
class Circle < Shape; end
class Hexagon < Shape; end

p Square.build(2).n
p Circle.build.n
