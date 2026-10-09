s = +"abc"
t = s
n = 0
begin
  n += 1
  t << "!"
  raise "x" if n < 2
rescue
  retry
end
p s
