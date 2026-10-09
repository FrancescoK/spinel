handlers = Hash.new(->(x) { $kept = x })
s = +"abc"
handlers[:nope].call(s)
s << "!"
p $kept
