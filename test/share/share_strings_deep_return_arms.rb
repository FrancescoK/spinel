# spinel: gc-minor
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

$g = "s".dup
def get_case(k)
  case k
  when 0 then $g
  else $g + "c"
  end
end
x = get_case(1)
x << "?"
p x, $g
