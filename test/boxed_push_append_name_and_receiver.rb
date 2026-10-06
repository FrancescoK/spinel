# push and append in statement position on a boxed receiver: only an Array
# (and a queue's push) has them. nil, a String or an Integer raises
# NoMethodError naming the method called, where the statement form went
# through `<<`: named '<<' for nil, concatenated onto a String and shifted
# an Integer.

def t
  yield
rescue NoMethodError, FrozenError => e
  puts "#{e.class}: #{e.message}"
end

k = ARGV.size
a = [nil, [1, "s"]][k]
t { a.push(3) }
t { a.append(3) }
t { a.push(3, 4) }
t { a << 5 }
s = [+"str", [1]][k]
t { s.push("y") }
t { s.append("z") }
p s
i = [2, [1]][k]
t { i.push(1) }
p i
r = [[1, "x"], 2][k]
r.push(9)
r.append(8)
r.push(7, 6)
p r
q = Thread::Queue.new
qq = [q, 1][k]
qq.push(5)
p q.size
t { p a.push(3) }
t { p s.append("w") }
