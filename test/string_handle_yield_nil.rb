# A String yielded into a proc that appends to it, where the yielding
# method is also handed nil (#6179).
class K
  def run(x, &b) = (@b = b; yield x)
end
k = K.new
s = +"a"
k.run(s) { |t| t << "!" if t; t }
p s
p k.run(nil) { |t| t << "?" if t; t }

def run(x) = yield(x)
def g(s) = (s << "g" if s; s)
pr = proc { |t| t << "p" if t; t }
u = +"u"
run(u, &pr)
p u
p run(nil, &pr)
run(u, &method(:g))
p u
p run(nil, &method(:g))
p run(nil) { |t| t }
