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

# self.m names the module's private singleton method too, and a method
# defined under a visibility call or module_function is its own as well
module Ext3
  def self.included(base)
    self.audit(base)
    puts "#{tagline} / #{short}"
  end
  def self.audit(b) = puts("audit #{b}")
  private_class_method :audit
  class << self
    private def tagline = "tagline"
  end
  module_function def short = "short"
end

# a module of the same last name elsewhere is not the hook's self: its
# singleton `describe` does not stand for the one the hook reaches
def describe(k) = "top-level describe of #{k}"
module Other
  module Plugin
    def self.describe(k) = "Other::Plugin.describe of #{k}"
  end
end
module Outer
  module Plugin
    def self.included(base)
      puts describe(base)
    end
  end
end

class A
  include Ext
end

class B
  include Ext
  extend Ext2
end

class D
  include Ext3
end

class E
  include Outer::Plugin
end

p Ext.seen
