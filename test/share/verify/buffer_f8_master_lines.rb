class U2
  def lines(*args, **kw) = ["u2"]
  def each_line(*args, **kw) = ["u2"]
end
def nf = +"-"
[+"a-b", U2.new].each do |a|
  p a.lines(nf, chomp: true)
end
