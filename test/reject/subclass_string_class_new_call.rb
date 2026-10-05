# Class.new(String) without a block makes its class at run time, and no
# class of the program's own stands for it: refused, naming the declaration
# that works (#7449). The block form is supported.
Label = Class.new(String)
p Label.new("x")
