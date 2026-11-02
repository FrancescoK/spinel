module Tbl
  H = { a: 1 }
  H.each { |k, v| const_set("K_#{k.upcase}", v) }
end
class Box
  def self.const_set(n, v) = :mine
end
p Tbl::K_A, Box.const_set(:X, 1)
