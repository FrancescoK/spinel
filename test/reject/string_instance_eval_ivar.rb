# An instance_eval block's @k is k's instance variable, written s itself,
# so the append to s is seen through k.k. It held a copy and stayed "abc":
# refused, not compiled wrong.
class K
  def k = @k
end
k = K.new
s = +"abc"
k.instance_eval { @k = s }
s << "!"
p k.k
