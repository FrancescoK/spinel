# An alias keeps the method it named when the alias ran; a later def of
# the original name replaces only that name. A recursion through the
# original name reaches the version defined when the call runs.
def f(n) = n <= 0 ? 0 : 1 + f(n - 1)
p f(3)
alias g f
p g(3)
def f(n) = 100
p g(3), f(3)

def e(n) = n <= 0 ? 0 : 1 + e(n - 1)
alias c e
def e(n) = n <= 0 ? 100 : 10 + e(n - 1)
p c(3), e(3)
