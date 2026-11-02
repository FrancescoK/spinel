# extended: obj.extend(M) at the top level fires the hook with the object
module M
  def self.extended(o) = puts("ext #{o.class}")
  def hi = "hi"
end
o = Object.new
o.extend(M)
puts o.hi
