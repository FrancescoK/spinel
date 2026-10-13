# spinel: reject-subclass: (CallNode `class_eval`)
# A class_eval given a proc runs it with self the class, which a proc here
# cannot be rebound to: refused, where it used to be dropped as if it were a
# reopen with nothing in it.
class Host
  installer = proc { |k| puts "installing into #{k}" }
  class_eval(&installer)
end
