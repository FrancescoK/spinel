# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# A chain of readers longer than the walk that follows them, handing the
# identity Set to a method: not followed, so every Set's calls are checked.
require "set"

class Seen
  def r12 = r11
  def r11 = r10
  def r10 = r9
  def r9 = r8
  def r8 = r7
  def r7 = r6
  def r6 = r5
  def r5 = r4
  def r4 = r3
  def r3 = r2
  def r2 = r1
  def r1 = @seen
  def initialize = @seen = Set.new.compare_by_identity
end

def look(s) = s.include?("x")
p look(Seen.new.r12)
