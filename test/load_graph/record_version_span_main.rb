# The load record's spans (--dump-load-record,
# record_version_span_main.rb.load-record): over each version's interval,
# the versions of its name a call can reach there, one for each stretch
# between changes on the class's chain in which a statement may run the
# program's code (idle: none does). An instance method counts only once an
# instance can exist: not before the class's first body ends, unless that
# body may run the program's code itself, so Bell's include, in a first
# body that runs none, changes nothing a call sees. No object of the
# program's exists before the first statement that runs its code (the
# first `puts`), so Bell's `map` cannot reach Base#to_s; Drum's, after it,
# may, and Drum's include lands where an instance may see it: unknown.
module Chime
  def ring = "chime"
end

class Base
  def to_s = "a base"
end

class Bell < Base
  def ring = "bell 1"
  SIZES = [1, 2].map { |n| n * 2 }
  include Chime
end

class Pod < Base
  def ring = "pod 1"
end

puts Pod.new.ring

class Drum < Base
  def ring = "drum 1"
  SIZES = [1, 2].map { |n| n * 2 }
  include Chime
end

class Gong < Base
  def ring = "gong 1"
  def ring = "gong 2"
end

class Bell
  def ring = "bell 2"
end

class Pod
  def ring = "pod 2"
end

class Drum
  def ring = "drum 2"
end

puts Bell.new.ring, Pod.new.ring, Drum.new.ring, Gong.new.ring
