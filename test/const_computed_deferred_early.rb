def Object.read(name)
  const_get(name)
end
begin
  p Object.read(:A)
rescue NameError => e
  puts e.message
end
A = 1
p Object.read(:A)
