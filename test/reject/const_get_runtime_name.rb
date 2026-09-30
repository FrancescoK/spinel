# const_get with a name known only at run time lowers to a static dispatch
# over the program's constants when it has a class or module receiver
# (test/const_get_dynamic.rb). In an instance method it has none to lower
# onto -- an instance has no const_get -- so it is refused where it is
# written, rather than typing nothing and failing at run time (#4843).
class Cart
  def klass(name) = const_get(name)
end
p Cart.new.klass("Cart")
