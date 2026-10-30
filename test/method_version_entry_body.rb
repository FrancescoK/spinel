# A call that runs while one version of a method is defined and again
# after a later def replaces it answers the version defined when it runs:
# from a method body, a default argument, a singleton method of main, and
# a recursion whose redefinition replaces the method it calls.
def k = 1
def w = k + 10
def d(x = k) = x + 100
def self.s = k + 1000
p w, d, s
def k = 3
p w, d, s

def g = 1
def f = g
p f
def g = 2
p f

def r(n) = n <= 0 ? 0 : 1 + r(n - 1)
p r(3)
def r(n) = n <= 0 ? 100 : 10 + r(n - 1)
p r(3)

def h(a, b) = "h1 #{a} #{b}"
def via(a, b) = h(a, b)
puts via(1, 2)
def h(a, b) = "h2 #{a} #{b}"
puts via(3, 4)
