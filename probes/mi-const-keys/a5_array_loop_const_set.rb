class Calc
  %i[SIZE NONCE].each_with_index { |n, i| const_set(n, i + 10) }
  def self.info = [SIZE, NONCE]
end
class Small
  [:SIZE].each { |n| const_set(n, 4) }
end
p Calc.info, Small::SIZE, Calc::SIZE
