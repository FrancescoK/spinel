# ARGV's Strings are frozen: a mutation raises FrozenError, a copy is mutable

def try
  yield
rescue FrozenError => e
  puts "#{e.class}: #{e.message}"
end

p ARGV[0].frozen?
p ARGV.first.frozen?
ARGV.each { |s| p s.frozen? }
p ARGV.frozen?

try { ARGV[0] << "x" }
s = ARGV[0]
try { s.upcase! }
try { ARGV.last.sub!(/1/, "9") }
p ARGV

d = ARGV[0].dup
p d.frozen?
d << "y"
p d
u = +ARGV[1]
u << "!"
p u

x = ARGV[2] || "lit"
p x
p ARGV[1].to_i + 1
p ARGV[0] + "!"
p ARGV.map(&:upcase)
