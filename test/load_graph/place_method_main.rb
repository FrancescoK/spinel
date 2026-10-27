# A require in a method body loads its file when the method is first called,
# and answers true then, false after (CRuby's Kernel#require). The file only
# defines a class.
def setup = require_relative("place_method_lib")
p setup
p setup
puts Foo.new.hi
