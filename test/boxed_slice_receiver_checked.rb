# slice on a boxed receiver: a Hash takes its keys, a String, a Symbol or
# an Array slices as `[]` does, and anything else raises NoMethodError
# naming slice, with the arguments as its args. Through `[]`, nil's error
# named `[]` and an Integer answered a bit. The arguments run before the
# receiver is tested, as in CRuby. A boxed Symbol's [int] is its name's.

def t
  yield
rescue NoMethodError => e
  puts "#{e.message} #{e.args.inspect}"
end

k = ARGV.size
[[10, 20, 30], "hello", :symbol, {a: 1, b: 2}, nil, 5, 2.5].each do |v|
  b = [v, nil][k]
  if v.is_a?(Hash)
    p b.slice(:a)
    p b.slice(:a, :b)
  else
    t { p b.slice(1) }
    t { p b.slice(1, 2) }
    t { p b.slice(0..1) }
  end
end
s = ["hello", 1][k]
p s.slice(/l+/)
p s.slice("ell")

log = []
n = [nil, [1]][k]
t { (log << :r; n).slice((log << :a0; 0), (log << :a1; 1)) }
p log
log.clear
a = [[1, 2, 3], nil][k]
p (log << :r; a).slice((log << :a0; 1), (log << :a1; 5))
p log

sy = [:symbol, nil][k]
p sy[1]
p sy[-2]
