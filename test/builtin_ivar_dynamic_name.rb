# Builtin ivar reflection validates evaluated names before its fallback.
# spinel: gc-minor
["x", "@", "@@x", "@1", "@x!", "@x\0y", "@valid", "@café"].each do |name|
  begin
    p "s".instance_variable_get(name)
  rescue NameError
    puts "NameError"
  end
  begin
    p [].instance_variable_defined?(name)
  rescue NameError
    puts "NameError"
  end
end
[:bad, :@valid].each do |name|
  begin
    p 1.instance_variable_get(name)
  rescue NameError
    puts "NameError"
  end
end
name = +"x"
begin
  p "s".instance_variable_defined?(name)
rescue NameError
  puts "NameError"
end
name = 42
begin
  p "s".instance_variable_get(name)
rescue TypeError
  puts "TypeError"
end
def receiver
  puts "receiver"
  1
end
def bad_name
  puts "name"
  "x"
end
def value
  puts "value"
  2
end
begin
  receiver.instance_variable_set(bad_name, value)
rescue NameError
  puts "NameError"
end
