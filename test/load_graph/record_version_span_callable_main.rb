# The load record's spans (--dump-load-record,
# record_version_span_callable_main.rb.load-record) for callables: a
# lambda, an at_exit block or a method object counts as running from where
# it is made, though it is called later. Bell's object is made only in a
# lambda, Drum's only in an at_exit block, Gong's only in a class method a
# method object holds, each made before its class's redefinition and run
# after it; Pod has no object until the last line.
module Chime
  def ring = "chime"
end

class Bell
  def ring = "bell 1"
end

class Drum
  def ring = "drum 1"
end

class Gong
  def ring = "gong 1"
  def self.make = new.ring
end

class Pod
  def ring = "pod 1"
end

LATER = -> { Bell.new.ring }
at_exit { puts Drum.new.ring }
MAKE = Gong.method(:make)

class Bell
  include Chime
end

class Drum
  include Chime
end

class Gong
  include Chime
end

class Pod
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

class Pod
  def ring = "pod 2"
end

puts LATER.call, MAKE.call, Pod.new.ring
