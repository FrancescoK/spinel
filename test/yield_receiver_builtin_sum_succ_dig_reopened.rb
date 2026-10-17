# A program's own reopening of sum/succ/dig on Array/Integer still wins over
# ty_recv_builtin_result's per-site arms, same precedence K-025's reopen
# dispatch already established for first/last/sort/etc.
class Array
  def sum = "reopened-sum"
  def dig(*a) = "reopened-dig"
end
def sum_of = yield.sum
p sum_of { [1, 2] }
p sum_of { [1.5, 2.5] }

def dig_of = yield.dig(0)
p dig_of { [1, 2] }
p dig_of { ["a", "b"] }

class Integer
  def succ = "reopened-succ"
end
def succ_of = yield.succ
p succ_of { 5 }
