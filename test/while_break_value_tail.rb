# A while/until whose valued break is the last statement of a begin, a
# method body, a branch, a block or a lambda yields the break value.
y = begin; while true; break 7; end; end; p y
u = begin; until false; break 12; end; end; p u
i = 0
q = begin; i += 1; while i < 5; i += 1; break i * 2 if i == 3; end; end; p q
r = begin; while false; end; end; p r
t = begin; while true; break "s"; end; end; p t

def m; while true; break 10; end; end; p m
def m2; begin; while true; break 11; end; end; end; p m2
def a(f); if f; while true; break 1; end; else; 2; end; end
p a(true), a(false)
def b(n); case n; when 1 then until false; break "one"; end; else :x; end; end
p b(1), b(2)
pr = proc { while true; break 3; end }
p pr.call
l = -> { i = 0; while i < 10; i += 1; break i if i == 4; end }
p l.call
def c; begin; while true; break 5; end; rescue; 0; end; end
p c
def d(x); while x > 0; x -= 1; break :hit if x == 2; end; end
p d(5), d(1)
def e; x = begin; while true; break [1, 2]; end; end; x.size; end
p e
def f; while true; break; end; end
p f
class K; def g; while true; break @v = 9; end; end; end
p K.new.g
