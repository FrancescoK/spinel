# A Random reopening's direct call passes its escaping block parameter.
class Random
  def capture(n = 1, &block)
    [n, block]
  end
end
r = Random.new(1)
a = r.capture(7) { 42 }
p a[0], a[1].call
b = r.capture
p b[0], b[1]
handler = proc { "proc" }
c = r.capture(3, &handler)
p c[0], c[1].call
