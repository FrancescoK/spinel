# An inherited class method calling another class method on self, bare or as
# `self.m`, reaches the override of the class it runs on, two levels down too.

class Runnable
  def self.filter(options = {}) = self.runnable_methods
  def self.pick = runnable_methods
  def self.run_suite = p([to_s, filter, pick])
  def self.runnable_methods = raise(NotImplementedError, "subclass responsibility")
end

class Test < Runnable
  def self.runnable_methods = ["test_a:#{self}"]
end

class Spec < Test; end
class AddTest < Test; end

p AddTest.filter
p AddTest.pick
[Test, Spec, AddTest].each { |k| k.run_suite }

module NS
  class Base
    def self.describe = "#{name_part}!"
    def self.name_part = self.label
    def self.label = "base"
  end
  class Mid < Base
    def self.label = "mid"
  end
end
class Leaf < NS::Mid; end
[NS::Base, NS::Mid, Leaf].each { |k| p k.describe }
p Leaf.describe

begin
  Runnable.run_suite
rescue NotImplementedError => e
  p e.message
end
