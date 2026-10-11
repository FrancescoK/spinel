# A def is the Symbol it names where its value is used, and only there is
# the name a Symbol of the program: a def whose value a statement list,
# the program or a class body throws away leaves the symbol runtime out
# (#8401).
p(def shown = 1)
x = def kept = 2
p x
class K
  def first = 1
  def last_in_body = 2
end
module M
  def self.unused = 3
end
def outer
  def inner = 4
end
p outer
p shown + kept + K.new.first + K.new.last_in_body + M.unused + inner
