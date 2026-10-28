# The load record's spans (--dump-load-record,
# record_version_span_main.rb.load-record): over each version's interval,
# the versions of its name a call can reach there, one for each stretch
# between changes on the class's chain in which a statement may run the
# program's code (idle: none does). An instance method counts only once an
# instance can exist: from the first statement that may make one of the
# class or a subclass of it. No Bell or Drum exists before the last `puts`
# (Base's to_s, which a call may reach, makes none either), so their
# includes change nothing a call sees, before the program's code first
# runs (the first `puts`) and after it. The record_version_span_*_main.rb
# tests make one in a body.
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
