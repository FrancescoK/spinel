module Tbl
  H = { a: 1, b: 2 }
  H.each { |k, v| const_set("K_#{k.upcase}", v) }
end
module Other
  K_A = 9
end
p Tbl::K_A, Tbl::K_B, Other::K_A
