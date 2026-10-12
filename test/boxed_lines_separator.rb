s = [1, "a,b,c"][1]
t = "a,b,c"
sep = [nil, ","][1]
nsep = [",", nil][1]
isep = [1, ","][0]
ns = ARGV.empty? ? nil : ","
x = "a\n\nb\nc\n"

p s.lines(sep)
p s.lines(sep, chomp: true)
p t.lines(sep)
p t.lines(sep, chomp: true)
p s.lines(nsep)
p t.lines(nsep)
p x.lines(nsep, chomp: true)
p s.each_line(sep).to_a
r = []
s.each_line(sep) { |l| r << l }
p r
p x.lines(ns)
p x.lines(ns, chomp: true)
p "".lines(ns)
p x.lines(nil)
p x.lines("")

begin
  t.lines(isep)
rescue TypeError => e
  p e.message
end
begin
  s.lines(isep)
rescue TypeError => e
  p e.message
end
