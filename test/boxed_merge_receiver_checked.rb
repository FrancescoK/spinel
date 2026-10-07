# merge on a boxed receiver: only a Hash has it, so nil or an Integer read
# out of a mixed value raises NoMethodError, with the argument as its args.
# A Hash still merges, whatever its keys.

def t
  yield
rescue NoMethodError => e
  puts "#{e.message} #{e.args.inspect}"
end

k = ARGV.size
h = [nil, {a: 1}][k]
t { p h.merge({b: 2}) }
i = [1, {a: 1}][k]
t { p i.merge({b: 2}) }
n = k == 0 ? nil : {"a" => 1}
t { p n.merge({"b" => 2}) }
s = [:sym, {}][k]
t { p s.merge({}) }
t { p h.merge }
o = [{x: 1}, nil][k]
t { p o.merge({y: 2}) }
w = [{"k" => [1]}, 2][k]
t { p w.merge({"k" => 3, 4 => :v}) }
