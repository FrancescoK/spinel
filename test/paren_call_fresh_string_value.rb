# A call in parentheses after another statement, `(k += 1; pair(x = +"l",
# y = +"r"))`, answers the new String its method makes, as the call does
# without the parentheses: written to a local beside the Strings its
# arguments wrote, which are then changed in place, it is no copy of them.
def pair(a, b) = "#{a}/#{b}"
k = 0
r = (k += 1; pair(x = +"l", y = +"r"))
x << "1"
y << "2"
p (k += 1; [r, x, y])
p k
