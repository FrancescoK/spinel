# The load record's spans (--dump-load-record,
# record_version_span_core_main.rb.load-record) for core classes: their
# objects exist from the first statement (a literal, an exception the
# runtime raises), so a method a program adds to one is seen from its def,
# even when the program never calls new on it. A program's subclass of a
# core class starts with no object: Fizz has none until the last line.
module Chime
  def ring = "chime"
end

class ZeroDivisionError
  def ring = "zero 1"
end

class Integer
  def ring = "integer 1"
end

class Fizz < ZeroDivisionError
  def ring = "fizz 1"
end

def divide(n) = 10 / n

FIRST = begin
  divide(0)
rescue ZeroDivisionError => e
  e.ring
end

class ZeroDivisionError
  include Chime
end

class Integer
  include Chime
end

class Fizz
  include Chime
end

class ZeroDivisionError
  def ring = "zero 2"
end

class Integer
  def ring = "integer 2"
end

class Fizz
  def ring = "fizz 2"
end

puts FIRST, Fizz.new.ring, 8.ring
