# An Array passed to a parameter its method stores other kinds into is
# widened to the general Array where the argument is built: the literal, an
# empty one, `Array.new`, or a method's answer. An argument written
# `(log << 1; [1, 2])` was not followed through the sequence, so the typed
# Array was refused ("the parameter is a general Array and the argument would
# be copied into it") or, as the value of an element, a hash value or `||=`,
# raised "cannot store String into an Array[Integer]" when the Array was
# stored into later.
$log = []
def lg(x) = ($log << x; x)

def mkary = [1, 2]
def st1(z) = (z << "str"; z << 2.5; z)
def st2(z) = (z << "str"; z << 2.5; z)
def st3(z) = (z << "str"; z << 2.5; z)
def st4(z) = (z << "str"; z << 2.5; z)
def st5(z) = (z << "str"; z << 2.5; z)

p st1((lg(:a); [1, 2]))
p st2((lg(:b); Array.new(2, 0)))
p st3((lg(:c); mkary))
p st4(((lg(:d); lg(:e); [3])))
p st5((lg(:f); []))

# the Array is read back out of an element, a hash value, or `||=`, and stored into
y = [(lg(:g); [1, 2])][0]
y << "elem"
p y
h = {k: (lg(:h); [1, 2])}[:k]
h << "hval"
p h
w = nil
w ||= (lg(:i); mkary)
w << "orw"
p w
p $log
