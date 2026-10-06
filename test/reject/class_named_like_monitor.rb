# CRuby makes a new class App::Monitor, and the top-level Monitor stays
# the builtin one. Spinel cannot keep the two apart, so it refuses.
module App
  class Monitor
    def hi = "mine"
  end
end

puts App::Monitor.new.hi
p Monitor.new.respond_to?(:hi)
