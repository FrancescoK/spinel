s = +"abc"
r = nil
begin
  raise s
rescue => e
  r = e.message
end
r << "!"
p s
p r
