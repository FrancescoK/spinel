class U1
  def pack(fmt) = "u1"
end
def nf = +"C"
[[65], U1.new].each do |a|
  p a.pack(nf)
end
