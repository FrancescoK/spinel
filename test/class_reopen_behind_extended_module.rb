# A method `class Class` adds is found after the modules a class extends:
# the singleton's ancestors list the extended modules before Class, and a
# module Class prepends sits in front of Class only (activesupport's
# DescendantsTracker, extended into a class with callbacks, answers
# descendants ahead of core_ext's Class#descendants).
module Tracker
  def descendants = [:tracker]
end

module Filtering
  def descendants = [:filtering]
  def subclasses_of = [:filtering_sub]
end

class Class
  def descendants = [:class]
  def label = "class:#{name}"
  prepend Filtering
end

module Hook
  def self.included(base)
    base.class_eval do
      extend Tracker
    end
  end
end

class Direct
  extend Tracker
end

class ViaHook
  include Hook
end

class Plain; end

class Own
  extend Tracker
  def self.descendants = [:own]
end

class Sub < Direct; end

p Direct.descendants, ViaHook.descendants, Plain.descendants, Own.descendants, Sub.descendants
p Direct.label, Plain.subclasses_of
