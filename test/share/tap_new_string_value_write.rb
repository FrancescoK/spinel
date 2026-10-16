# The value of tap over a new String, written to a variable, is the String
# the block changed (#9258)
i = 1
x = "a#{i}".tap { |t| t << "!" }
x << "?"
p x
y = (+"b").tap { |t| t << "!" }
z = y
z << "?"
p y, z.equal?(y)
w = "c#{i}".tap { |t| t.upcase! }
p w
