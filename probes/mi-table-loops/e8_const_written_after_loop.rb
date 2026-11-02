module Tbl
  H = { a: 1 }
  H.each { |k, v| const_set("K_#{k.upcase}", v) }
  def self.k = K_A
end
p Tbl.k
