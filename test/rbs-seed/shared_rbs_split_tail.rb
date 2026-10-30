# Under --share-strings (#6765), a method an --rbs signature declares
# `(String) -> String` whose last value reads one element of a new Array
# of new Strings (`col.split(".").last.to_s`), beside a `return col` that
# answers its parameter, hands its answer on as the String a container
# then shares: the element is a new String no name holds, so the method
# clears the return's side channel there, and the caller makes the handle
# for it. Before, the handle walk took only Strings its facts kept apart
# (share_node_fresh), the element read joined the container's class, and
# every store of the answer into a container the rule shares was refused.
# The same method called as the second element of a chained `<<` stores
# its handle too, as it does as a statement of its own (the store walk saw
# only the first push of a chain): into a local Array, an ivar's and the
# Array an Hash element holds, and where the method is one of a class and
# its subclass (the dispatch boxes each arm's answer), and where it yields
# its answer (the inlined call answers the handle its `return` and its tail
# hold), where an early `return x` stands beside a tail that reads an ivar
# (the call is not the ivar's slot), and where the `return` is a `tap`
# whose block parameter is the handle.
class ShstCols
  def initialize
    @where = []
    @cols = []
  end
  attr_reader :where, :cols

  def name_of(col)
    return col unless col.include?(".")
    col.split(".").last.to_s
  end

  def first_of(col)
    return col if col.empty?
    col.split("-").first
  end

  def nth_of(col, i)
    col.split(",")[i].to_s
  end

  def push_cols(cols)
    @where << cols.map { |c| c }
    self
  end

  def chain(a, b)
    @chain = []
    @chain << name_of(a) << name_of(b)
    @chain
  end

  def add(h)
    @cols = []
    h.each do |key, val|
      if val.is_a?(Hash)
        val.each do |col, v|
          @cols << name_of("#{key}.#{col}")
        end
      else
        @cols << name_of(+key.to_s)   # (+: a Symbol's to_s is frozen in Spinel)
      end
    end
    @cols << first_of(+"p-q") << first_of(+"") << nth_of(+"x,y", 1) << nth_of(+"x", 3)
    push_cols(@cols)
  end
end

r = ShstCols.new
r.add({ a: 1, "z" => 2, b: { c: 3 } })
r.where[0][0] << "!"
r.where[0][2] << "?"
r.where[0][3] << "1"
r.where[0][4] << "2"
r.where[0][5] << "3"
p r.where, r.cols
p r.cols.map { |s| s.equal?(r.where[0][r.cols.index(s)]) }

k = +"plain"
o = []
o << r.name_of(+"x.y") << r.name_of(k)
o[1] << "?"
p o, k, o[1].equal?(k)
j = +"other"
c = r.chain(+"a.b", j)
c[1] << "!"
p c, j, c[1].equal?(j)
q = +"third"
h = { a: [] }
h[:a] << r.name_of(+"m.n") << r.name_of(q)
h[:a][1] << "#"
p h, q

class ShstBase
  def initialize
    @s = +"held"
  end
  attr_reader :s

  def m(col)
    return col unless col.include?(".")
    col.split(".").last.to_s
  end
end

class ShstSub < ShstBase
  def m(col)
    return col unless col.include?(".")
    @s
  end
end

objs = [ShstBase.new, ShstSub.new]
q = +"q.r"
z = +"plain"
d = []
objs.each { |x| d << x.m(+"a.b") << x.m(q) << x.m(z) }
w = d.map { |e| e }
w.each { |e| e << "!" }
p d, w, objs.map(&:s), q, z
p d.each_index.map { |i| d[i].equal?(w[i]) }

class ShstYield
  def m(col)
    return col unless col.include?(".")
    yield col.split(".").last
  end
end

y = ShstYield.new
kept = []
yk = +"plain"
yo = []
yo << y.m(+"x.y") { |e| kept << e; e } << y.m(+"z.w") { |e| e.dup } << y.m(yk) { |e| e }
yo << y.m(yk) { |e| e }
yw = yo.map { |e| e }
yw.each { |e| e << "!" }
p yo, yw, kept, yk
p yo[0].equal?(kept[0]), yo[2].equal?(yk), yo[3].equal?(yk)

class ShstIv
  def initialize
    @iv = +"ivv"
  end

  def m(x)
    return x if x.size < 3
    @iv
  end
end

iv = ShstIv.new
iy = +"xy"
ir = []
ir << iv.m(iy)
ir << +"a" << iv.m(iy) << iv.m(+"long")
iy << "2"
ir[3] << "!"
p ir, iy, ir[0].equal?(iy), ir[2].equal?(iy), ir[3].equal?(iv.m(+"long"))

class ShstTap
  def m(x)
    return x.tap { |t| t } if x.size > 2
    yield x
    +"tail"
  end
end

tp = ShstTap.new
ts = +"abc"
tr = []
tr << tp.m(ts) { |v| v }
tr << tp.m(ts) { |v| v } << tp.m(+"ab") { |v| v }
ts << "1"
p tr, ts, tr[0].equal?(ts), tr[1].equal?(ts)
