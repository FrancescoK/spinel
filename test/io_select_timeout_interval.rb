# spinel: gc-stress
# IO.select's and Kernel#select's timeout converts as a time interval:
# nil waits -- written, or held in a variable, a parameter, a keyword or a
# box, one that can hold a number too included -- a number waits that
# long, and anything else raises CRuby's TypeError.
def check
  p yield
rescue => e
  p [e.class, e.message]
end

def arg(n, value)
  p n
  value
end

def sel(io, timeout = nil) = IO.select([io], nil, nil, timeout)

def sel_timeout(timeout) = IO.select([], [], [], timeout)

def sel_kw(io, t: nil) = select([io], nil, nil, t)

def sel_opt(io, t = nil) = Kernel.select([io], nil, nil, t)

r, w = IO.pipe
w.write("x")

check { IO.select([], [], [], "x") }
s = "x"
check { IO.select([], [], [], s) }
check { IO.select([], [], [], ["x", 0][0]) }
check { sel_timeout("x") }
check { IO.select([], [], [], :x) }
check { IO.select([], [], [], true) }
check { IO.select([], [], [], false) }
check { IO.select([], [], [], [1]) }
check { IO.select([], [], [], {a: 1}) }
check { IO.select([], [], [], Object.new) }
check { select([], [], [], "y") }
check { Kernel.select([r], nil, nil, :z) }
check { IO.select(arg(1, []), arg(2, nil), arg(3, []), arg(4, "x")) }

t = nil
check { IO.select([r], nil, nil, t)[0] == [r] }
check { sel(r)[0] == [r] }
check { IO.select([r], nil, nil, [nil, 1.5][0])[0] == [r] }
check { IO.select([r], nil, nil, nil)[0] == [r] }
check { IO.select([r])[0] == [r] }
check { IO.select([], [], [], 0) }
check { IO.select([], [], [], 0.0) }
check { IO.select([r], nil, nil, 0.to_r)[0] == [r] }
check { sel(r, 0.0)[0] == [r] }
check { sel_kw(r)[0] == [r] }
check { sel_kw(r, t: 0.5)[0] == [r] }
check { sel_opt(r)[0] == [r] }
check { sel_opt(r, 1)[0] == [r] }
x = rand < 2 ? nil : 1
check { IO.select([r], nil, nil, x)[0] == [r] }
z = rand < 2 ? 0.0 : nil
check { IO.select([], [], [], z) }
r.close
w.close
