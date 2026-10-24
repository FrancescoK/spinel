class Foo; end

def try
  yield
rescue TypeError => e
  p [e.class, e.message]
end

try { "x".instance_exec(&7) }
try { "x".instance_exec(&2.5) }
try { "x".instance_exec(&"s") }
try { "x".instance_exec(&[1]) }
try { "x".instance_exec(&(1..2)) }
try { "x".instance_exec(&Foo.new) }
b = 7
try { "s".instance_exec(&b) }
try { "s".instance_eval(&3.5) }

log = []
r = ->(x) { log << :recv; x }
a = ->(x) { log << :arg; x }
try { r.("y").instance_exec(a.(1), &(log << :blk; 7)) }
p log

try { "x".instance_exec(&true) }
try { "x".instance_eval(&false) }
tv = true
try { "s".instance_exec(&tv) }

log2 = []
r2 = ->(x) { log2 << :recv; x }
a2 = ->(x) { log2 << :arg; x }
try { r2.("y").instance_exec(a2.(1), &(log2 << :blk; true)) }
p log2

log3 = []
r3 = ->(x) { log3 << :recv; x }
a3 = ->(x) { log3 << :arg; x }
try { r3.("y").instance_eval(a3.(1), &(log3 << :blk; true)) }
p log3
