# A call in the statements of a parenthesized endless def, `def m = (a; b)`,
# reaches the version of a method that is defined when it runs, as a call in
# an ordinary body does: the statements are the def's own, and nothing walks
# up from them to the parentheses the def dropped.
def one(x) = x + 1
def twice(x) = (one(x); one(one(x)))
p twice(1)
def one(x) = x + 100
p twice(1)

def each_two = (yield 1; yield 2)
def sum_two = (t = 0; each_two { |x| t += x }; t)
p sum_two
def each_two = (yield 10; yield 20)
p sum_two

def pair(a) = [a, a]
def both = (pair(1); pair(2))
p both
def pair(a) = [a + 1, a + 2]
p both
