# In M.included(base) self is M, also when the hook body is spliced into
# the including class: `self` reads M, and a receiverless call of M's own
# singleton method (private too) goes to M. In a class_eval block self is
# the class.
module Ext
  def self.included(base)
    note(base)
    p self
    [1].each { p self }
    tag = label
    puts "#{base} labelled #{tag}"
    base.class_eval do
      p self
    end
    record(base)
  end

  def self.note(b) = puts("note #{b}")

  class << self
    def label = "ext"
  end

  def self.record(b) = (@seen ||= []) << b.name
  private_class_method :record

  def self.seen = @seen
end

module Ext2
  def self.extended(base)
    p self
    greet(base)
  end
  def self.greet(b) = puts("hello #{b}")
end

class A
  include Ext
end

class B
  include Ext
  extend Ext2
end

p Ext.seen
