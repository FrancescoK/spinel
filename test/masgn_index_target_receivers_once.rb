# spinel: gc-stress
# The index and attribute targets of a multiple assignment that sit after the
# first, in a nested (a, b), after the splat or beside it, take their receiver
# and key once, left to right, before the right side runs: an Array, a Hash, an
# object with its own []= and a Struct, each read through a call that logs.
$log = []
class Idx
  def initialize; @h = {}; end
  def []=(k, v); @h[k] = v; end
  def [](k) = @h[k]
end
S3 = Struct.new(:a, :b)
ARR = [0, 0, 0, 0, 0]
HSH = {}
IDX = Idx.new
STC = S3.new(0, 0)
def arr
  $log << "arr"
  ARR
end
def hsh
  $log << "hsh"
  HSH
end
def idx
  $log << "idx"
  IDX
end
def stc
  $log << "stc"
  STC
end
def k(tag, v)
  $log << tag
  v
end
def vals
  $log << "vals"
  [10, [20, 30], 40, 50]
end

arr[k("ka", 0)], (hsh[k("kh", 7)], idx[k("ki", 1)]), *rr, arr[k("kb", 4)] = vals
p $log, ARR, HSH, IDX[1], rr
$log.clear
(stc.b, arr[k("kc", 2)]), hsh[k("kd", 8)] = [7, 8], 9
p $log, STC.b, ARR, HSH
$log.clear
*rr2, arr[k("ke", 1)], idx[k("kf", 2)] = 1, 2, 3
p $log, ARR[1], IDX[2], rr2
