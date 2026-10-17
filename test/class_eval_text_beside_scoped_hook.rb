# A class body's `class_eval "def ..."` is grafted even in a program whose
# other classes hook method definitions for themselves: a class's own
# `class << self; def method_added`, a `def self.singleton_method_added`,
# and an instance method named method_added of a class that is no Module
# run for no other class. (A Kernel#class_eval, for plain objects, is left
# out as before.)
module Kernel
  def class_eval(*args, &block) = raise("Kernel#class_eval")
end

class Watcher
  class << self
    def method_added(name) = (@seen ||= []) << name
    def seen = @seen
  end
  def watched = 1
end

class Notifier
  def self.singleton_method_added(name) = nil
end

class Event
  def method_added(name) = name
end

module Silence
  def self.included(base); base.class_eval do
    class_eval "@@silencer = true; def self.silencer = @@silencer; def silencer = @@silencer"
  end; end
end

class Log
  include Silence
  class_eval "def a = 1"
  class_eval <<-RUBY, __FILE__, __LINE__ + 1
    def b = 2
  RUBY
end

p Log.new.a
p Log.new.b
p Log.silencer
p Log.new.silencer
p Watcher.seen
p Event.new.method_added(:x)
