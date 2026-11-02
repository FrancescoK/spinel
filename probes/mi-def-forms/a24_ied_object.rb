o = Object.new
o.instance_eval { def m = :om }
p o.m
