$g = "s".dup
def get(k)
  case k
  when 0 then $g
  else $g + "c"
  end
end
x = get(1)
x << "?"
p x, $g
