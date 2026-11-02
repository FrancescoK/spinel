module Tbl
  H = { a: 1 }
  H.each { |k, v| const_set("K_#{k.upcase}", v) }
end
class Symbol
  def upcase = :changed
end
p Tbl::K_A, :a.upcase
