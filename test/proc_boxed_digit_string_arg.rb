# A boxed String of digits past the Integer word reaches a block's
# parameter as itself. The call fills the parameter's int slot
# speculatively, and that fill reads the String without raising: a block
# that never reads it as a number ran no further (#10462).
pr = proc { |a| puts a }
pr.call(["9" * 100, 1][0])
pr.call(["12", 1][0])
l = lambda { |a| a.size }
p l.call(["9" * 40, 2][0])
def take(&b) = b.call(["8" * 30, 3][0])
p take { |s| s + "!" }
h = { "7" * 25 => 1 }
h.each_key { |k| p k.length }
