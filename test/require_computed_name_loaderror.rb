# A require whose name is computed at run time names no file the program was
# compiled with: it raises LoadError, which the usual fallback rescues.
v = "9.9"
begin
  require "no_such_lib/#{v}/native"
  p :loaded
rescue LoadError => e
  p e.message
end
begin
  require_relative "no_such_dir/#{v}/native"
rescue LoadError => e
  p e.class
end
ok = begin
  require "no_such_lib/#{v}"
rescue LoadError
  false
end
p ok
