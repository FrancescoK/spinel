s = +"abc"
r = nil
begin
  raise RuntimeError, s
rescue => e
  r = e.message
end
r << "!"
p s
p r
