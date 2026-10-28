# A singleton def through a constant that names a class, `def F2.baz`
# where `F2 = Foo`, defines on Foo's singleton: the load record's frame
# and receiver give the def its owner.
class Foo
  def self.bar = :bar
end
F2 = Foo
def F2.baz; :baz; end
p Foo.baz, F2.baz, Foo.bar
p Foo.singleton_methods.sort
