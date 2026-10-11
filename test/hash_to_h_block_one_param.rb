# Hash#to_h yields the key and the value as two values: a block of one
# parameter binds the key, as CRuby's does (#8505), and two parameters
# still bind both.
p({a: 1}.to_h { |key| [key, 0] })
p({"x" => 1, "y" => 2}.to_h { |k| [k.upcase, k] })
p({a: 1, b: 2}.to_h { |k, v| [v, k] })
p({a: 1}.to_h { |(k, v)| [k, v] })
