# StringIO#print and #puts with more than three arguments. The package
# declared bindings for up to three, and a longer call fell back to the
# first binding of the name: print wrote only its first argument and puts
# wrote a bare newline. Through a parameter that also receives a File the
# call had no arm at all and raised NoMethodError for the File.
require "stringio"
require "tmpdir"

s = StringIO.new
s.print("a", "b", "c", "d")
s.puts("e", "f", "g", "h")
r = s.print(1, :k, nil, 2.5, "\n")
p r
s.puts(1, [2, [3]], nil, :y)
p s.string

def emit(io)
  io.print("a", "b", "c", "d", "e", "\n")
  io.puts(1, 2, 3, [4, 5])
  io.puts([6, [7]])
end

path = File.join(Dir.tmpdir, "sp_stringio_print_puts_many_args_#{Process.pid}.txt")
File.open(path, "w") { |f| emit(f) }
t = StringIO.new
emit(t)
p File.read(path)
p t.string
emit($stdout)
File.delete(path)
