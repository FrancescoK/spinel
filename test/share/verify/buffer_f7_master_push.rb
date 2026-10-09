class U2
  def push(*args, **kw) = "u2"
  def include?(*args, **kw) = "u2"
  def index(*args, **kw) = "u2"
end
def nf = +"-"
[[1, 2], U2.new].each do |a|
  p a.include?(nf)
  p a.index(nf)
  p a.push(nf)
end
