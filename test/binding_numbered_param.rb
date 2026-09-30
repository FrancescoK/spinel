begin
  proc { _1; binding.local_variable_get(:_1) }.call(1)
rescue NameError => e
  p [e.message, e.name]
end

begin
  proc { _2; binding.local_variable_get(:_2) }.call(1, 2)
rescue NameError => e
  p [e.message, e.name]
end

begin
  [3].map { it; binding.local_variable_get(:_1) }
rescue NameError => e
  p [e.message, e.name]
end

begin
  proc { _1; binding.local_variable_defined?(:_1) }.call(1)
rescue NameError => e
  p [e.message, e.name]
end

begin
  proc { _1; binding.local_variable_set(:_1, (puts "value first"; 5)) }.call(1)
rescue NameError => e
  p [e.message, e.name]
end

x = proc { _1 * 2 }.call(21)
p binding.local_variable_get(:x)
