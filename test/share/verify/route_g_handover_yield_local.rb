def m
  y = +"a"
  yield y
  y
end
kept = nil
r = m { |v| kept = v }
r << "!"
p kept
