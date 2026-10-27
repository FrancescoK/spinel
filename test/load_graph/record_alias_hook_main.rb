# A definition form whose hook the program defines only through an alias
# (--dump-load-record, record_alias_hook_main.rb.load-record): the required
# file aliases Struct's method_added, so the attr_accessor in a Struct.new
# block, a class the load record does not know, may run code of the
# program's, which a global read before its first write would see. The
# record answers it by the names the program defines methods by, the
# alias's included, taken as it is made.
require_relative "record_alias_hook_lib"
Pt = Struct.new(:a) do
  attr_accessor :x
end
pt = Pt.new(1)
pt.x = 2
p pt.a, pt.x
