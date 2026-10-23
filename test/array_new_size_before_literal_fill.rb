# Array.new(n, v) evaluates n before v when v is a literal the C builds
# ahead of the call, an Array or a Hash: its elements ran before the size
# expression. (An interpolated String was already in order.)
$log = []
def size(n) = ($log << :size; n)
def fill(v) = ($log << :fill; v)

p Array.new(size(2), [fill(1), 2])
p Array.new(size(2), {a: fill(3)})
p Array.new(size(1), "x#{fill(4)}")
p Array.new(size(2), [fill(1.5)])
begin
  Array.new(size(-1), [fill(5)])
rescue ArgumentError => e
  $log << e.message
end
p $log
