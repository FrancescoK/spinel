# A program's own reopening of sum/succ/dig on Array/Integer still wins over
# the new per-site table arms (Tasks 1-3), same precedence K-025's reopen
# dispatch already established for first/last/sort/etc.
class Array
  def sum = "reopened-sum"
end
def sum_of = yield.sum
p sum_of { [1, 2] }
p sum_of { [1.5, 2.5] }

class Integer
  def succ = "reopened-succ"
end
def succ_of = yield.succ
p succ_of { 5 }
