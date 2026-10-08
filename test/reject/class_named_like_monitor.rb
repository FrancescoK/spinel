# CRuby makes a new class App::Monitor, and the top-level Monitor stays
# the builtin one. Spinel cannot keep the two apart, so it refuses.
# spinel: reject-builtin-class: unsupported class name 'Monitor': collides with the builtin class of that name
module App
  class Monitor
    def hi = "mine"
  end
end

puts App::Monitor.new.hi
p Monitor.new.respond_to?(:hi)
