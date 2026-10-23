# A boxed parameter subject keeps the refusal.
class Sc
  def scan(re) = yield(+"q")
end
def f(x, acc)
  x.scan(/./) { |m| acc << m; m << "!"; x << "z" if acc.size == 1 && x.is_a?(String) }
  x
rescue => e
  [e.class, e.message]
end
acc = []
p f(+"abc", acc)
p f(Sc.new, acc) rescue p $!.class
p acc
