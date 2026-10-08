# spinel: gc-minor
# Flag-only: a concrete method's byte return carries its published handle
# into an Array element. A proved fresh call clears the channel instead.
class ReturnElement
  def initialize(x) = @x = x
  def fresh = @x + "c"
  def get(k)
    $calls += 1
    k == 0 ? @x : fresh
  end
end
$calls = 0
src = "s".dup
a = ReturnElement.new(src)
arr = [a.get(1), a.get(0)]
arr[0] << "#"
arr[1] << "!"
p arr, src, $calls
# Reverse the order and mutate after an allocation large enough to grow.
arr = [a.get(0), a.get(1)]
arr[1] << "long" * 50
arr[0] << "?"
p src, arr[0], arr[1].size, $calls
