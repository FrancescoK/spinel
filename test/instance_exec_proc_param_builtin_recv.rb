def on_str(b) = "r".instance_exec(5, &b)
def on_int(b) = 7.instance_exec(5, &b)
def on_ary(b) = [1, 2].instance_exec(5, &b)
p on_str(proc { |a| [self, a] })
p on_int(proc { |a| [self, a] })
p on_ary(proc { |a| [self, a] })

S = "c"
def on_const(b) = S.instance_exec(5, &b)
p on_const(proc { |a| [self, a] })
def on_param(s, b) = s.instance_exec(5, &b)
p on_param("v", proc { |a| [self, a] })
def on_expr(t, b) = t.upcase.instance_exec(&b)
p on_expr("loc", proc { self })

blk = proc { |a| [self, a] }
p "t".instance_exec(7, &blk)
lam = ->(a) { [self, a] }
p 3.instance_exec(8, &lam)
p "free".instance_exec(9, &proc { |a| a * 2 })
