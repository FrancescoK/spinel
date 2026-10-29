# main's `class << self` method and Object's `def` of one name are two
# methods: a call at the top level finds main's, one on another object
# Object's. A top-level def that calls neither by that name is no concern.
class << self
  def k = "sc"
end
def k = "obj"
p k
p Object.new.send(:k)
def w = 3 + 4
p w
