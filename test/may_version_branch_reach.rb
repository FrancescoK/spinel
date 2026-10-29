# A def under a run-time condition is sure to have run for a call after it in
# its own branch and not for one after the branch; a later redefinition
# changes both. The calls reach the version defined when they run: at the top
# level, through a method that calls it, and on an instance of a class whose
# body holds the condition.
flag = [1, 2].sum == 3
def k = "a"
def via_k = k
if flag
  def k = "b"
  p k
  p via_k
else
  def k = "e"
  p k
end
p k
p via_k
def k = "c"
p k
p via_k

class Box
  def v = "v1"
  def get = v
  if [3, 4].sum == 7
    def v = "v2"
    p new.v
    p new.get
  end
  p new.v
  p new.get
  def v = "v3"
  p new.v
  p new.get
end
p Box.new.v
p Box.new.get

# the condition false: the else arm's def is the one that ran
def m = "m1"
def via_m = m
if [1, 2].sum == 4
  def m = "m2"
  p m
else
  def m = "m3"
  p m
  p via_m
end
p m
p via_m
def m = "m4"
p m
p via_m

# a def in an iterator's block, which may run no time: a call after it in the
# block is sure to have it, one after the block is not
def n = "n1"
def via_n = n
[1].each do
  def n = "n2"
  p n
  p via_n
end
p n
p via_n
def n = "n3"
p n
p via_n

# a def in a begin body with a rescue clause
def r = "r1"
def via_r = r
begin
  def r = "r2"
  p r
rescue ArgumentError
  p :rescued
end
p r
p via_r
def r = "r3"
p r
p via_r
