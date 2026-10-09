s = +"abc"
def m0(x) = x
def m1(x) = m0([x])[0]
def m2(x) = m1([x])[0]
def m3(x) = m2([x])[0]
def m4(x) = m3([x])[0]
def m5(x) = m4([x])[0]
def m6(x) = m5([x])[0]
def m7(x) = m6([x])[0]
def m8(x) = m7([x])[0]
def m9(x) = m8([x])[0]
def m10(x) = m9([x])[0]
def m11(x) = m10([x])[0]
r = m11(s)
r << "!"
p s
