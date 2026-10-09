s = +"abc"
begin
  raise ArgumentError, s
rescue => e
  e.message << "!"
end
p s
