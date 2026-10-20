# A Hash passed to a parameter its method stores other kinds of keys and
# values into is widened where it is built: the literal or a method's answer.
# The argument that was `(log << 1; {a: 1})` was not followed through the
# sequence, and the program was refused ("a typed Hash is passed to `st`'s
# parameter ... which the method stores keys or values of other types into").
$log = []
def lg(x) = ($log << x; x)

def st(z)
  z["k"] = "v"
  z[:z] = 1.5
  z
end

def mkhash = {a: 1}

p st((lg(:a); {a: 1}))
p st((lg(:b); mkhash))
p st(((lg(:c); lg(:d); {b: 2})))
p $log
