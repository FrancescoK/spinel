# receiverless (deep-return pickup), rescue arm fresh
$g = "s".dup
def get(f)
  begin
    raise "x" if f
    $g
  rescue
    $g + "r"
  end
end
x = get(true)
x << "?"
y = get(false)
y << "!"
p x, y, $g
