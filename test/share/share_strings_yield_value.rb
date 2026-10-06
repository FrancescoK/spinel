# Flag-only: without the flag (as on master) the answer is a copy when the
# String is not otherwise shared.
# A method that answers its yield's value, called with a block that answers
# a String the rule shares, answers that String itself, as CRuby does.
def hy_id(v) = yield(v)

def hy_twice(v)
  n = 0
  n += 1
  yield(v)
end

s = +"hello"
t = hy_id(s) { |q| q }
s << "~"
p [s, t]

s2 = +"hello"
t2 = hy_id(s2) { |q| q }
p [t2.equal?(s2), t2.object_id == s2.object_id]
t2.freeze
p [s2.frozen?, t2.frozen?]

s3 = +"abc"
t3 = hy_twice(s3) { |q| q }
t3 << "!"
p s3

# the block answers a String of its own: a copy, as CRuby's
s4 = +"xy"
t4 = hy_id(s4) { |q| q + "" }
t4 << "!"
p [s4, t4]
