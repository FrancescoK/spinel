# A top-level method with a `super` that nothing calls: the compiler looked up
# the superclass of a scope that has no class and read outside its class
# table, which crashed it depending on what else the program held.
def task
  t = super
  t
end

$h = { "x" => 1.abs }
p $h
