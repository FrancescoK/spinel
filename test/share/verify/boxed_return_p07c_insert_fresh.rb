src = "s".dup
arr = [src + "c"]
arr.insert(1, src + "c")
arr.each_with_index { |s, i| s << i.to_s }
p arr
