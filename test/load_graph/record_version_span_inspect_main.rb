# A first body that may make an instance (record_version_span_main.rb): `p`
# calls Shown#inspect by itself, and that makes a Drum, so an instance of
# Drum may exist before Drum's first body ends, and the include that
# follows lands where it can be seen (--dump-load-record: unknown).
module Chime
  def ring = "chime"
end

class Shown
  def inspect
    $made = Drum.new
    "shown"
  end
end

SEED = Shown.new

class Drum
  def ring = "drum 1"
  p SEED
  include Chime
end

puts $made.ring

class Drum
  def ring = "drum 2"
end

puts $made.ring, Drum.new.ring
