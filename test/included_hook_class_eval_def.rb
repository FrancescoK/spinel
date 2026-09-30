# A def inside `base.class_eval do ... end` in a module's `self.included`
# or `self.extended` hook defines the method on the including class: the
# hook runs at the include site, where `base` is that class. The shape was
# taken for a class held in a variable and replaced with a raise before
# the hook was inlined, so neither the instance nor the class method
# existed (the pattern ActiveSupport::Concern's `included do` stands for).
module Loggable
  def self.included(base)
    base.class_eval do
      @log = []
      def self.log = @log
      def self.record(event) = (@log << event; self)
      def note(event) = self.class.record(event)
    end
  end
end

module Tagged
  def self.extended(base)
    base.class_eval do
      def self.tag = "tag:#{name}"
    end
  end
end

class Order
  include Loggable
  extend Tagged
end

class Ticket
  include Loggable
end

Order.new.note(:a)
Order.new.note(:b)
Ticket.new.note(:c)
p Order.log, Ticket.log, Order.tag
p Order.new.respond_to?(:note), Order.respond_to?(:record)
