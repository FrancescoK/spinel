# A `return` in a define_method block or a lambda inside M.included(base)
# leaves that block, not the hook: the hook still shapes the includer.
module Shaped
  def self.included(base)
    base.class_eval do
      define_method(:kind) { return :shaped }
    end
    check = ->(x) { return x * 2 }
    puts "check #{check.call(21)}"
  end
end

class Seen
  include Shaped
  puts "after include in Seen"
end

p Seen.new.kind
