class Bus
  def initialize(flag)
    @h = flag ? {a: 1, "s" => 2} : [10, 20]
  end
  def fe(k) = @h.fetch(k) { |x| x.to_s * 2 }
  def fd(k) = @h.fetch(k, 5)
  def fsym = @h.fetch(:z) { |k| k.to_s }
  def fstr = @h.fetch("s") { |k| k.upcase }
  def fmiss = @h.fetch("q") { |k| k.upcase }
  def fidx = @h.fetch(7) { |i| i * 3 }
end
b = Bus.new(true)
p b.fsym, b.fstr, b.fmiss, b.fidx
p b.fe(:a), b.fe(:y), b.fd(:a), b.fd(:y)
c = Bus.new(false)
p c.fidx
p c.fe(1), c.fe(4), c.fd(0), c.fd(9)
