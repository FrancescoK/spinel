# A String parameter a block or proc captures and appends to is the
# caller's String; left at a nil default it is nil, and the method runs
def rc(cmd, text: nil)
  return :none if text.nil?
  t = Thread.new { text << cmd }
  t.join
  :ok
end
p rc("a")
s = +""
p rc("b", text: s)
p s

def rp(cmd, text = nil)
  return :none if text.nil?
  pr = proc { text << cmd }
  pr.call
  :ok
end
p rp("a")
u = +""
p rp("c", u)
p u
