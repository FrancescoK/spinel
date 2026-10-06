# A builtin Enumerable method on a boxed String, Symbol, Integer or Float
# whose class defines the name itself at another count: CRuby calls the
# class's own method, which raises ArgumentError for the count, where the
# Enumerable walk raised NoMethodError. A class without the name, and an
# Array, are unchanged.

def t
  p yield
rescue => e
  puts "#{e.class}: #{e.message}"
end

k = ARGV.size
["sa", :sy, 5, 2.5, nil, [1, 2]].each do |v|
  n = [v, 0][k]
  t { n.partition { |x| x } }
  t { n.count }
  t { n.count { |x| x } }
  t { n.include?(1, 2) }
  t { n.min(1, 2) }
  t { n.group_by { |x| x } }
end
