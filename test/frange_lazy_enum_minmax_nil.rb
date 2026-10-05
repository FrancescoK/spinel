# A blockless iterating method of a Float Range (each, map, min_by,
# max_by(n), ...) answers its Enumerator in CRuby, which raises
# `can't iterate from Float` only when it walks; Spinel raised at the call,
# on a typed, a boxed and a nil-or-value receiver.
# And Array#min / #max / #min_by / #max_by and Hash#min_by / #max_by read a
# nil count as no count, where Spinel raised the count's TypeError.

def t(k)
  r = (0.5..2.5)
  n = nil
  [-> { r.min_by.class }, -> { r.max_by(1).class }, -> { r.each.class }, -> { r.map.class },
   -> { r.select.first }, -> { r.each.to_a }, -> { r.map.next }, -> { r.min_by { |x| x } },
   -> { (..2.5).each.to_a }, -> { r.find_index.class },
   -> { [(0.5..2.5), :x][k].max_by(1).class }, -> { q = k == 0 ? r : nil; q.min_by.class },
   -> { [(0.5..2.5), :x][k].each.to_a }, -> { [[1, 2], :x][k].each.to_a },
   -> { [3, 1, 2].min(nil) }, -> { [3, 1, 2].max(n) }, -> { [3, 1, 2].min_by(nil) { |x| x } },
   -> { {1 => 2, 3 => 0}.max_by(n) { |kk, v| v } }, -> { [1.5, 0.5].min(nil) },
   -> { (1..3).min(nil) }, -> { [3, 1, 2].min(1) }].each do |f|
    p f.call
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
end
t(ARGV.size)
