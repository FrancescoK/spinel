# A receiverless or `self.` call in an instance method of a class reaches an
# instance method and never a class method of the same name, so a `def self.m`
# that nothing calls stays dead, even when its body could only raise. A
# module's instance method keeps the bare-name mark: extend runs it with a
# class as self.
class Store
  def initialize; @h = {}; end
  def []=(k, v); @h[k] = v; end
  def [](k) = @h[k]
  def save(v) = (self[:v] = v; self)
  def label = "store"
  def self.label
    self[:v] = 1
    "class"
  end
  def tag = "tag"
  def self.tag
    self[:t] = 1
    "class tag"
  end
  def to_s = label
  def tagged = self.tag
end

module Helpers
  def build = make
end

class Kit
  extend Helpers
  def self.make = "made"
end

p Store.new.save(3)[:v]
p Store.new.to_s
p Store.new.tagged
p Kit.build
