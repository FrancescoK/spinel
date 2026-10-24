# An implicit-self call in a class or module method, of a method the
# program defines on Object: self is the class, an Object, so CRuby finds
# Object's method. It raised NameError for a bare identifier, where the
# same call written `self.current_part` answered (#10079).
class Object
  def current_part = "w1"
  def name_of(x) = "<#{x}>"
end
class K
  def self.go = p(current_part)
  def self.tag = name_of(1)
  def self.name_check = name
end
K.go
p K.tag
p K.name_check
module Solo
  def self.go = p(current_part)
end
Solo.go
