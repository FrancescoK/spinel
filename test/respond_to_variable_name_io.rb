# respond_to? with a method name held in a variable, on an IO: the answer
# is a boxed true or false wherever a value is wanted.
f = File.open(__FILE__)
p %i[puts path nope].map { |m| f.respond_to?(m) }
p %i[puts nope].map { |m| $stderr.respond_to?(m) }
s = "x"
p %i[upcase nope].map { |m| s.respond_to?(m) }
p %i[push nope].map { |m| [1].respond_to?(m) }
%i[puts nope].each do |m|
  puts(f.respond_to?(m) ? "y" : "n")
  puts "if" if f.respond_to?(m)
  puts "not" unless f.respond_to?(m)
  r = f.respond_to?(m)
  p r, !f.respond_to?(m), (f.respond_to?(m) && m == :puts)
end
def ok?(io, m) = io.respond_to?(m)
p ok?($stdout, :write), ok?($stdout, :nope)
p [$stderr, 1].map { |v| v.respond_to?(%i[puts][0]) }
p %i[puts nope].map { |m| f.respond_to?(m, true) }
p %w[puts nope].map { |m| f.respond_to?(m) }
