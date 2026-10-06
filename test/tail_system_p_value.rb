# A method, block or lambda whose last expression is system(cmd) answers the
# command's success, and one ending in p(x) answers x (#6553)
def ok
  system "true"
end
def bad = system("false")
def none = system("exit 3")
def pp1 = p(5)
def pr1 = print("")
def pu1 = puts("")
def cond(x)
  if x
    system "true"
  else
    system "false"
  end
end
p ok, bad, none, cond(true), cond(false)
p pp1, pr1, pu1
def r1
  begin
    system "true"
  rescue
    nil
  end
end
def pm = p(1, 2)
def pn = p
l = -> { system "false" }
blk = [1].map { system "true" }
p r1, pm, pn, l.call, blk
def kubectl(cmd) = system("test #{cmd}")
p kubectl("-n x"), kubectl("-z x")
