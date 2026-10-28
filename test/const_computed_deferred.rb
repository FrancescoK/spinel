def Object.read(name)
  const_get(name)
end
p :before
A = 1
p Object.read(:A)
