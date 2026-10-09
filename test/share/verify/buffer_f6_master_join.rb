class U2
  def join(*args, **kw) = "u2"
end
def nf = +"-"
[[1, 2], U2.new].each do |a|
  p a.join(nf)
end
