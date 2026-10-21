# A message and the String it was raised with are one String when the program
# compares them through values of no known type: the elements of Arrays built
# in place, the parameters of a method that compares whatever it is given.
def chk(a, b) = a.equal?(b)

s = +"msg"
i = ARGV.size
begin
  raise s
rescue => e
  p [e.message, 1][i].equal?([s, 2][i])
  p chk(e.message, s), chk(s, e.message), chk(e.message, +"msg")
  p [s, 1][i].object_id == [e.message, 2][i].object_id
end

t = +"two"
begin
  raise RuntimeError, t
rescue => e
  p chk(e.message, t), chk(e.message, e.message), chk(t, t.dup)
end

# a receiver of no known type that holds the message, or another String, or
# a value of another class, compared with the message read again
n = ARGV.size
x = StandardError.new(+"bm#{n}")
z = n == 0 ? x.message : 3
p z.equal?(x.message), z.equal?(x.to_s)
w = n == 0 ? (+"other") : 3
p w.equal?(x.message)
