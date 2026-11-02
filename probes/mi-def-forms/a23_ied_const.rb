class K; end
p((K.m rescue :nomethod))
K.instance_eval { def m = :m }
p K.m
