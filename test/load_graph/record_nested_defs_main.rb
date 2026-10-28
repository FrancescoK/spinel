# A def in an argument or a written value (`keep def m`, `x = def y`) is a
# definition of its class where its statement runs, as a def statement is
# (--dump-load-record, record_nested_defs_main.rb.load-record); so is one
# a visibility word or module_function takes.
class A
  def self.keep(name) = name
  keep def m = 1
  x = def n = 2
  p x
  p(private def o = 3)
  def all = [m, n, o]
end
module M
  module_function def f = 4
end
p A.new.all, M.f
p A.public_instance_methods(false).sort, A.private_instance_methods(false).sort
