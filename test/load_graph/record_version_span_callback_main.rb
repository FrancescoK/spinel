# The load record's first-run points (--dump-load-record,
# record_version_span_callback_main.rb.load-record, runs=) for methods
# CRuby calls without a call site naming them: case/when's ===, case/in's
# deconstruct, respond_to? asking respond_to_missing?, Float()'s to_f,
# sum's +, raise's exception, `&:new`, include's append_features, and a
# refinement's method, whose owner is the refining module, which nothing
# instantiates. Each first version runs where that call is, before its
# redefinition, so its body counts from there, never as one that does not
# run. The record only: the compiler refuses refinements and binds these
# calls to the last versions, so the program has no .expected.
module Mix
  def self.append_features(base)
    base.instance_variable_set(:@mixed, 1)
    super
  end
end

module Shout
  refine String do
    def shout = upcase + "!"
  end
end
using Shout

class Matcher
  def ===(x) = x == 1
end

class Pt
  def deconstruct = [1, 2]
end

class Probe
  def respond_to_missing?(name, priv = false) = name == :zz
end

class Num
  def to_f = 1.5
end

class Money
  attr_reader :n
  def initialize(n) = @n = n
  def +(o) = Money.new(n + o.n)
end

class Err
  def exception(msg = nil) = RuntimeError.new("err 1")
end

class Bell
  def ring = "bell 1"
end

out = []
case 1
when Matcher.new then out << "matched"
end
case Pt.new
in [a, b] then out << a + b
end
out << Probe.new.respond_to?(:zz)
out << Float(Num.new)
out << [Money.new(1), Money.new(2)].sum(Money.new(0)).n
begin
  raise Err.new
rescue => e
  out << e.message
end
out << [Bell].map(&:new).first.ring
class Host
  include Mix
end
out << "a".shout

class Matcher
  def ===(x) = false
end

class Pt
  def deconstruct = [3, 4]
end

class Probe
  def respond_to_missing?(name, priv = false) = false
end

class Num
  def to_f = 2.5
end

class Money
  def +(o) = Money.new(n + o.n + 100)
end

class Err
  def exception(msg = nil) = RuntimeError.new("err 2")
end

class Bell
  def ring = "bell 2"
end

module Mix
  def self.append_features(base)
    base.instance_variable_set(:@mixed, 2)
    super
  end
end
module Shout
  refine String do
    def shout = upcase + "?"
  end
end

puts out, Host.instance_variable_get(:@mixed)
