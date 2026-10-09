# A frozen literal as a default argument, a lambda's answer or a block's
# answer is one object across evaluations, beside a shared String.
SRC = +"src"
def dflt(k, a = "dflt") = k == 0 ? a : SRC
x = dflt(0)
y = dflt(0)
p x.equal?(y), x.frozen?, dflt(0, "dflt").equal?(x)
w = [dflt(1), dflt(0), 3]
w[0] << "!"
p SRC, w[1].equal?(x)
def only(a = "dflt") = a
q = [only, only, only(SRC)]
p q[0].equal?(q[1]), q[0].equal?("dflt")
q[2] << "?"
p SRC

l = ->(k) { k == 0 ? "lit" : SRC }
pr = proc { |k| k == 0 ? "lit" : SRC }
m = [l.(0), l.(0), pr.(0), pr.(0), l.(1)]
p m[0].equal?(m[1]), m[2].equal?(m[3]), m[0].equal?(m[2])
m[4] << "~"
p SRC
mm = 3.times.map { |i| i == 0 ? SRC : "lit" }
p mm[1].equal?(mm[2]), mm[1].equal?(m[0])
mm[0] << "^"
p SRC

def pick(k) = k == 0 ? "lit" : SRC
def cased(k)
  case k
  when 0 then "lit"
  when 1 then SRC
  else "other"
  end
end
r = [pick(0), pick(0), cased(0), cased(0), cased(2), cased(2), 1]
p r[0].equal?(r[1]), r[2].equal?(r[3]), r[0].equal?(r[2]), r[4].equal?(r[5])
c = cased(1)
c << "&"
p SRC
