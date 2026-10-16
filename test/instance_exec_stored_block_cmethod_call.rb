# A block handed to a method that keeps it, later run with instance_exec on
# another class, calls a class method on the self it is run with: through
# `self.`, bare, and from a class body. Its call compiled to the class
# method of the class the block was written in.

class Base
  def self.tag = :base
  def self.add(x) = x + 1
end
class Ctl < Base
  def self.tag = :ctl
  def self.add(x) = x + 100
end

HOOKS = []
def on_load(&blk) = HOOKS << blk

class Engine
  def self.tag = :engine
  def self.add(x) = x + 10
  on_load { p [:body, tag, add(1)] }
  on_load { p [:body_self, self, self.tag] }
  def self.setup
    on_load { p [:cmethod, self, self.tag] }
    on_load { p [:bare, tag, self.add(2)] }
  end
end
Engine.setup

HOOKS.each { |h| h.call }
HOOKS.each { |h| Base.instance_exec(&h) }
HOOKS.each { |h| Ctl.instance_exec(&h) }
