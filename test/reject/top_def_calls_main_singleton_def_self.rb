# A top-level def is one function with no self of its own here, and its
# receiverless call of a name main has a singleton method for finds main's
# method when the def runs on main and Object's when it runs on another
# object. CRuby prints "sc" for the call from main; the def is refused.
def self.k = "sc"
def k = "obj"
def w = k
p w
