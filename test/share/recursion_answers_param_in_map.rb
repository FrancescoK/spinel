# A method that answers its parameter through a call of itself (`pass(x,
# n - 1)`) answers the caller's argument: its recursive call hands the
# parameter back to the slot it came from, and the caller's own flow of the
# answer keeps the argument, not the parameter, so a new String passed in
# is a new String out, held by the map's result (#9258 cluster 12).
def pass(x, n) = n == 0 ? x : pass(x, n - 1)
ys = [1, 2].map { |i| pass("v#{i}", 3) }
ys[0] << "!"
p ys
