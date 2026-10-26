# frozen_string_literal: true
require_relative 'hidden_ivars'

class HiddenHolder
  def initialize = @visible = 1
end
h = HiddenHolder.new
p CextHidden.stashed?(h)
p CextHidden.fetch(h)
CextHidden.stash(h, [1, "two"])
p CextHidden.stashed?(h)
p CextHidden.fetch(h)
p h.instance_variables
p h.inspect.include?("stash")
p h.instance_variable_get(:@visible)
CextHidden.keep(h)
GC.start
junk = []
1000.times { |i| junk << "x#{i}" * 10 }
GC.start
p CextHidden.fetch_kept(h)
other = HiddenHolder.new
p CextHidden.fetch(other)
p CextHidden.stashed?(other)
frozen = HiddenHolder.new.freeze
begin
  CextHidden.stash(frozen, 1)
rescue FrozenError => e
  p e.class
end
