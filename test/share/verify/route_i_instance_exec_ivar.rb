class K; def k = @k; end
k = K.new
s = +"abc"
k.instance_exec(s) { |x| @k = x }
s << "!"
p k.k
