# A reopening that redefines a method changes what a call already compiled
# into another method answers from then on, and not before: in the class
# itself, in a subclass that overrides a method it inherited, in a class
# whose call reached a top-level method before the class defined its own,
# in a module's singleton, on Object as a constant receiver, and on an
# object of a subclass that overrides the name.
class B
  def get = 1
  def twice = get * 2
end
b = B.new
p b.get, b.twice
class B
  def get = 5
end
p b.get, b.twice

class A
  def m = 1
  def t = m
end
class Sub < A
end
s = Sub.new
p s.t
class Sub
  def m = 2
end
p s.t, A.new.t

def pitch = "main"
class Bell
  def ring = "ring #{pitch}"
end
puts Bell.new.ring
class Bell
  def pitch = "bell"
end
puts Bell.new.ring

module Tone
  def self.tone = "low"
  def self.say = "say #{tone}"
end
puts Tone.say
module Tone
  def self.tone = "high"
end
puts Tone.say

# Object as a constant receiver, bare and rooted: the class method the
# call runs is the one defined when it runs, and a top-level method stays
# private to it
class Object
  def self.obj_tone = 1
end
def obj_tones = [Object.obj_tone, ::Object.obj_tone]
p obj_tones
class Object
  def self.obj_tone = 2
end
p obj_tones
def obj_bar = 1
def via_obj_bar = (Object.obj_bar rescue "private")
p via_obj_bar
def obj_bar = 2
p via_obj_bar

# an entry whose self may be a subclass that overrides the name
class Base
  def f = 1
  def g = f
end
class Over < Base
  def f = 5
end
base = Base.new
over = Over.new
p [base.g, over.g]
class Base
  def f = 2
end
p [base.g, over.g]
