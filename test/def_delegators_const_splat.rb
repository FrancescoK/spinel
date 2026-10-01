# def_delegators with the names in a constant, as Rack::Lint writes it:
# `def_delegators :@stream, *REQUIRED_METHODS`. The constant is a literal
# Symbol Array, on one line or several, frozen or not, or a %i list.
require "forwardable"

class Stream
  extend Forwardable
  REQUIRED = [
    :read, :write, :<<,
    :closed?
  ]
  NAMES = %i[size empty?].freeze
  MORE = [:last, :include?].freeze
  def_delegators :@io, *REQUIRED
  def_delegators :@arr, *NAMES, :first
  def_delegators :@arr, *MORE

  def initialize(io, arr) = (@io = io; @arr = arr)
end

class IOish
  def read = "r"
  def write(s) = s.size
  def <<(s) = self
  def closed? = false
end

s = Stream.new(IOish.new, [1, 2])
p s.read, s.write("abc"), s.closed?, (s << "x").class
p s.size, s.empty?, s.first, s.last, s.include?(2)

# the constant of the class body the call is in, not a nested class's
class Outer
  extend Forwardable
  NAMES = [:size]
  class Inner
    NAMES = [:empty?]
  end
  def_delegators :@a, *NAMES
  def initialize(a) = @a = a
end
o = Outer.new([1, 2, 3])
p o.size, o.respond_to?(:empty?)
