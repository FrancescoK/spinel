class P; def initialize(a, b) = (@a = a; @b = b); def to_s = "P #{@a} #{@b}"; end
class Q; def initialize(a, b = 1, c = 2) = (@a = a); def to_s = "Q #{@a}"; end
class R; def initialize(a, *r) = (@a = a); def to_s = "R #{@a}"; end
class K; def initialize(k:) = (@k = k); def to_s = "K #{@k}"; end
class X; def initialize(a, k:, j:) = nil; end
class W; def initialize(a, k: 1) = (@a = a); def to_s = "W #{@a}"; end
class Z; def to_s = "Z"; end
class O; def initialize(a = 1) = (@a = a); def to_s = "O #{@a}"; end
class Sub < P; end
class E < StandardError; end
S = Struct.new(:x, :y)
D = Data.define(:x, :y)
KS = Struct.new(:a, keyword_init: true)
OS = Struct.new(:a, :b) do
  def initialize(a) = super(a, 0)
end

def t(label)
  puts "#{label} ok #{yield}"
rescue ArgumentError => e
  puts "#{label} AE #{e.message}"
rescue NoMethodError => e
  puts "#{label} NME #{e.message}"
end

arr = [P, Q, R, K, X, W, Z, O, Sub, E, S, D, KS, OS]
t("P1") { arr[0].new(1) }
t("P3") { arr[0].new(1, 2, 3) }
t("P0") { arr[0].new }
t("P2") { arr[0].new(1, 2) }
t("Q0") { arr[1].new }
t("Q4") { arr[1].new(1, 2, 3, 4) }
t("Q2") { arr[1].new(1, 2) }
t("R0") { arr[2].new }
t("R1") { arr[2].new(1) }
t("K1") { arr[3].new(1) }
t("X0") { arr[4].new }
t("X1") { arr[4].new(1) }
t("W2") { arr[5].new(1, 2) }
t("W1") { arr[5].new(1) }
t("Z1") { arr[6].new(1) }
t("Z0") { arr[6].new }
t("O2") { arr[7].new(1, 2) }
t("O1") { arr[7].new(5) }
t("Sub1") { arr[8].new(1) }
t("E2") { arr[9].new(1, 2) }
t("S3") { arr[10].new(1, 2, 3) }
t("S1") { arr[10].new(1).to_a.inspect }
t("D0") { arr[11].new }
t("D1") { arr[11].new(1) }
t("D3") { arr[11].new(1, 2, 3) }
t("D2") { arr[11].new(1, 2).x }
t("KS1") { arr[12].new(1) }
t("OS2") { arr[13].new(1, 2) }
t("OS1") { arr[13].new(1).b }

h = { p: P, d: D }
t("hP1") { h[:p].new(1) }
t("hD1") { h[:d].new(1) }

flag = ARGV.empty?
k = flag ? P : Z
t("kP1") { k.new(1) }
t("kP0") { k.new }
k = flag ? Z : P
t("kZ1") { k.new(1) }
t("kZ0") { k.new }
k = flag ? D : Z
t("kD0") { k.new }
