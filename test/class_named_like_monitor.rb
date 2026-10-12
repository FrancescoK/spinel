# CRuby makes a new class App::Monitor, and the top-level Monitor stays
# the builtin one. The nested class takes the internal name App__Monitor,
# so the two stay apart.
require "monitor"

module App
  class Monitor
    def hi = "mine"
  end
end

puts App::Monitor.new.hi
p Monitor.new.respond_to?(:hi)
