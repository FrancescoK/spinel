# A curry realized past the 16 channel slots hands each String or object
# argument to the target as its pointer, as a spread call does; the slot
# took sp_poly_slot_i's number for them, and the target read "" (CodeRabbit
# on #10010).
class Box
  def initialize(v) = @v = v
  def to_s = "Box(#{@v})"
end
pr = proc { |a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18| [a1, a17.to_s, a18.to_s] }
c = pr.curry(18)
r = c[1][2][3][4][5][6][7][8][9][10][11][12][13][14][15][16]
p r["seventeen"][Box.new(18)]
l = ->(s, t, u) { s + t + u }
p l.curry["a"]["b"]["c"]
