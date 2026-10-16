# a class variable a module declares, read and written by its methods on a
# class that extends it: they are the class's class methods, and the
# variable is still the module's
module Handlers
  @@handlers = {}
  def register(ext, h) = @@handlers[ext] = h
  def handler_for(ext) = @@handlers[ext]
  def self.count = @@handlers.size
end
class Template
  extend Handlers
end
Template.register(:erb, "ERB")
Template.register(:raw, "Raw")
p Template.handler_for(:erb), Template.handler_for(:none), Handlers.count
