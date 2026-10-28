# The earlier body of a method defined again runs only between its def and
# the next one, so its calls reach the methods in effect there: its own
# name is that body (a recursion), and another name defined again later
# is that name's earlier definition too.
def f(n) = n <= 0 ? 0 : 1 + f(n - 1)
p f(3)
def f(n) = n <= 0 ? 100 : 10 + f(n - 1)
p f(3)
def g = 1
def h = g + 10
p h
def h = g + 20
def g = 2
p h
