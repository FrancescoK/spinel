# A store through a box can widen its Hash only after another Hash widened,
# when its value is a method's answer read out of that one: the parameter
# bound from the widened Hash and the return reading it follow only after
# the store that widened it. Every Hash the chain reaches sees its store.
# spinel: gc-minor
def read_x(h) = h["x"]
def read_one(h) = h[1]
def put_into(h, x)
  [h, 1][ARGV.size][0] = x
end
r0 = {"x" => 0}
r1 = {1 => 1}
rp = {0 => 0}
br = [r0, 1][ARGV.size]
br["x"] = "s"
[r1, 1][ARGV.size][1] = read_x(r0)
put_into(rp, read_one(r1))
p r0, r1, rp
