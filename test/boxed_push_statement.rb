# push and append are an Array's (and push a queue's). As a statement on a
# boxed receiver with one argument they were compiled as `<<`, which a String
# and an Integer answer: the String was appended to (or not), the Integer
# shifted, and the NoMethodError was lost.

def report
  yield
rescue NoMethodError => e
  puts "NoMethodError: #{e.message}"
end

s = [+"s", 5][0]
report { s.push("!") }
report { s.append("!") }
p s

n = [5, +"s"][0]
report { n.push(1) }
report { n.push("!") }
p n

# the argument runs before the method is missed
def arg
  puts "arg"
  1
end
report { n.push(arg) }

# the message names the method sent, not `<<`
f = [1.5, 5][0]
report { f.push(1) }
h = [{k: 1}, 5][0]
report { h.append(1) }
z = [nil, 5][0]
report { z.push(1) }

# an Array of each kind and a queue take the push as before
a = [[1], 5][0]
a.push(2)
a.append(3)
p a
b = [["a"], 5][0]
b.push("b")
p b
c = [[1, "a"], 5][0]
c.append(nil)
p c
q = [Queue.new, 5][0]
q.push(1)
p q.size

# `<<` stays a String's and an Integer's own
t = [+"s", 5][0]
t << "!"
p t
