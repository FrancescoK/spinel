# A bare call at main asks the modules main extends before the modules the
# top level includes.
module First
  def tag = "extend"
end
module Second
  def tag = "include"
end
extend First
include Second
p tag

# a top-level def's self is its caller's: from another class's method, the
# include answers
def top = tag
class K
  def im = top
end
p K.new.im

# an extended module's `def self.x` is not main's; a module_function's copy is
module Cm
  def self.label = "Cm-self"
end
module Mf
  module_function
  def label = "Mf-mf"
end
extend Cm
include Mf
p label
module Mf2
  module_function
  def label2 = "Mf2-mf"
end
module Inc2
  def label2 = "Inc2"
end
extend Mf2
include Inc2
p label2

# the class a bare call answers is the extended module's method's
class Foo
  def who = "Foo"
end
class Bar
  def who = "Bar"
end
module MakeB
  def make = Bar.new
end
module MakeA
  def make = Foo.new
end
include MakeB
extend MakeA
h = { k: make }
p h[:k].who

# with the include first, the extended module's `def self.x` is still not
# main's
module Cm3
  def self.label3 = "Cm3-self"
end
module Inc3
  def label3 = "Inc3"
end
include Inc3
extend Cm3
p label3

# a top-level `class << self` body's self is main's singleton class, which
# has the includes and not the extends
module Ext4
  def tag4 = 1
end
module Inc4
  def tag4 = "s"
end
extend Ext4
include Inc4
class << self
  x = tag4
  p x
  p x.upcase
end
