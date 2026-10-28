def Object.present(name)
  const_defined?(name)
end
p Object.present(:A)
A = 1
p Object.present(:A)
