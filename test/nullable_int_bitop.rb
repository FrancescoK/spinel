# Integer's &, | and ^ on a receiver that can be nil: NilClass answers them
# with a boolean (nil ^ 1 is true, nil & 1 false, nil | x is x's truth). The
# C read the nil sentinel's bits as a number, so `nil ^ 1` printed
# -9223372036854775807.

b = [1][5]          # nil, read past the end of an Integer array
c = [6][0]          # 6, from the same kind of read

# where the value is boxed anyway, nil answers its boolean
p(b ^ 1)
p(b & 1)
p(b | 1)
p(b | nil)
puts b ^ 1
print b & 1, "\n"
puts "#{b ^ 2} #{b | 0}"
h = {a: 1}
p(h[:z] ^ 5)
z = [6, "s"][0]      # a boxed local
z = b | 3
p z

# a value that is not nil keeps Integer's answer
p(c ^ 3)
p(c & 3)
p(c | 9)
p(h[:a] ^ 5)
z = c ^ 1
p z
k = c ^ 2
p k
def m(v) = v ^ 1
p m(7)

# An Integer slot cannot hold nil's boolean: there Spinel raises
# NotImplementedError naming CRuby's answer instead of reading the sentinel
# as a number. Each case prints CRuby's answer when the message says it.
def slot(msg)
  yield.inspect
rescue NotImplementedError => e
  e.message == msg ? msg[/answers (\w+)/, 1] : e.message
end
puts slot("nil ^ Integer answers true or false, which an Integer slot cannot hold") { y = b ^ 1; y }
puts slot("nil & Integer answers false, which an Integer slot cannot hold") { y = b & 1; y }
puts slot("nil ^ Integer answers true or false, which an Integer slot cannot hold") { m([1][3]) }
