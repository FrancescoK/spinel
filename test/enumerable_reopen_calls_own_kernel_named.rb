# A receiverless call in a method a program adds to Enumerable finds the
# program's own method of that name through self, as CRuby's lookup does,
# even when the name is also a private Kernel function (open, format,
# print). A Kernel-named call the program does not define still reaches
# Kernel's function. So is a method defined with `private def` or
# `protected def` (which an outside call still may not reach), one the
# program adds to Array (rand), one a module the program includes in Array or
# Range or prepends to Hash defines (test, and caller through a module nested
# in another), and one it adds to Integer, called from another of Integer's.
# The methods of a module included into or prepended to Enumerable reach an
# Array, a Hash and a Range too, directly and from a copy (trap), behind
# Enumerable's own def of a name when included and ahead of it when
# prepended, the last included first and of `include A, B` (or `prepend
# A, B`) A; a module method that calls super is not reached (a call of it
# still raises NoMethodError).
module Enumerable
  def call_open = open
  def open = 42
  def label = format("%d items", count)
  def format(f, n) = "own #{f} #{n}"
  def shout = print("hi")
  def print(s) = s.upcase
  def lines = sprintf("%d", 1)
end

p [1].call_open
p (1..3).call_open
p({ a: 1 }.call_open)
p [1, 2].label
p (1..4).label
p({ a: 1, b: 2 }.label)
p [1].shout
p (1..2).shout
p [1].lines
p({ a: 1 }.lines)

class Array
  def rand = :array_rand
end
module Enumerable
  def pick = rand
end
p [1, 2].pick

module Enumerable
  def call_warn = warn
  private def warn = 42
  def call_pp = pp
  protected def pp = :prot
end
p [1].call_warn
p (1..2).call_warn
p({ a: 1 }.call_warn)
p [1].call_pp
begin
  [1].warn
rescue NoMethodError => e
  puts e.message
end

module ArrayMix; def test = :array_mix; end
class Array; include ArrayMix; end
module HashMix; def test = :hash_mix; end
class Hash; prepend HashMix; end
module RangeMix; def test = :range_mix; end
class Range; include RangeMix; end
module Enumerable; def call_test = test; end
p [1].call_test
p({ a: 1 }.call_test)
p (1..2).call_test

module Outer
  module Nested; def caller = :nested; end
end
class Array; include Outer::Nested; end
module Enumerable; def call_caller = caller; end
p [1].call_caller

module EnumMix; def zork = 1; def trap = :enum_mix; end
module Enumerable; include EnumMix; def call_trap = trap; end
p [1].zork
p [1].call_trap
p (1..2).zork
p({ a: 1 }.zork)

module Deep2; def deep_name = :deep2; end
module Deep1; include Deep2; def mid_name = :deep1; end
module Enumerable; include Deep1; end
p [1].deep_name
p (1..2).mid_name

module Behind; def both = :behind; def only_behind = :behind_only; end
module Enumerable; include Behind; def both = :enumerable; end
p [1].both
p({ a: 1 }.only_behind)

module Ahead; def front = :ahead; end
module Enumerable; prepend Ahead; def front = :enumerable_front; end
p [1].front

module Secret; private def hidden = :secret; def reveal = hidden; end
module Enumerable; include Secret; end
p [1].reveal

module First; def order = :first; end
module Second; def order = :second; end
module Enumerable; include First; include Second; end
p [1].order

module ArgA; def arg_order = :arg_a; end
module ArgB; def arg_order = :arg_b; end
module Enumerable; include ArgA, ArgB; end
p [1].arg_order
module PreA; def pre_order = :pre_a; end
module PreB; def pre_order = :pre_b; end
module Enumerable; prepend PreA, PreB; def pre_order = :enumerable_pre; end
p [1].pre_order

module UpCall; def up_call = super; end
module Enumerable; include UpCall; end
begin
  p [1].up_call
rescue NoMethodError => e
  p e.class
end

class Integer
  def call_open = open
  def open = self * 10
end
p 4.call_open
