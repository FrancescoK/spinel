class K; def k = @k; end
k = K.new
s = +"abc"
k.instance_eval { @k = s }
s << "!"
p k.k
