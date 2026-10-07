def plain(o, m, *a) = o.send(m, *a)

p plain("ab", :upcase)
p plain([1, 2], :first)
p plain({x: 1}, :merge, {z: 3})
p plain({x: 1}, :merge, {y: 2}, {z: 3})
p plain({x: 1}, :merge, {x: 2}, {y: 3}, {x: 4})

def merge_all(h, a, b) = h.merge(a, b)
box = [{a: 1}, "s"]
p merge_all(box[0], {b: 2}, {a: 3})

begin
  plain(nil, :merge, {a: 1}, {b: 2})
rescue NoMethodError => e
  puts e.class
end
