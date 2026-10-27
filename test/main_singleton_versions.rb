# A call on main from a method of main's own runs the `k` main answers when
# the call runs: main's singleton `k` as it stands then, or Object's while
# main has none. A default argument's call runs inside the method too.
def k = 1
def self.k = 2
def self.w(x = k) = x + 10
p w
p k
def self.k = 3
p k
p self.k

def u = 1
def self.v = u
p v
def self.u = 2
p v
p u
