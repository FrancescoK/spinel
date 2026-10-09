class K
  %w[keep].each { |nm| define_method(nm) { |x| @k = x } }
  def k = @k
end
k = K.new
s = +"abc"
k.keep(s)
s << "!"
p k.k
