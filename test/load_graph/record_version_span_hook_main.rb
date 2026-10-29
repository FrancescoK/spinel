# The load record's spans (--dump-load-record,
# record_version_span_hook_main.rb.load-record) for hooks: a class-level
# hook runs at its definition form (here inherited, included and
# method_added), whether or not its owner has an object, so what it makes
# counts from there. Tracker, Mixer and Watch have no object until the
# last line; Bell's, Drum's and Gong's objects are made only by their
# hooks, so each one's first version is seen where its hook first runs.
module Chime
  def ring = "chime"
end

LOG = []

class Bell
  def ring = "bell 1"
end

class Drum
  def ring = "drum 1"
end

class Gong
  def ring = "gong 1"
end

class Tracker
  def self.inherited(sub)
    super
    LOG << Bell.new.class
  end
end

module Mixer
  def self.included(base)
    LOG << Drum.new.class
  end
end

class Watch
  def self.method_added(name)
    LOG << Gong.new.class if name == :tick
  end
end

class Sub < Tracker
end

class Host
  include Mixer
end

class Watch
  def tick = "tick"
end

class Bell
  include Chime
end

class Drum
  include Chime
end

class Gong
  include Chime
end

class Bell
  def ring = "bell 2"
end

class Drum
  def ring = "drum 2"
end

class Gong
  def ring = "gong 2"
end

puts LOG
puts Bell.new.ring, Drum.new.ring, Gong.new.ring, Watch.new.tick, Tracker.new.class, Host.new.class
