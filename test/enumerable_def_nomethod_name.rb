# A Ruby-implemented Enumerable method (builtins/enumerable.rb) called on
# a value that is no collection raises NoMethodError naming the method
# called, as CRuby does ("undefined method 'minmax' for an instance of
# Integer"); the walk of the receiver inside the definition named `each`.

def t(s)
  r = yield
  puts "#{s}: #{r.inspect}"
rescue NoMethodError => e
  puts "#{s}: #{e.message}"
end

class Nope; end
vals = [[3, 1, 2], 5, nil, :sym, 2.5, Nope.new]
vals.each do |v|
  t("minmax") { v.minmax }
  t("tally") { v.tally }
  t("each_with_object") { v.each_with_object([]) { |x, a| a << x } }
  t("filter_map") { v.filter_map { |x| x } }
  t("minmax_by") { v.minmax_by { |x| x } }
  t("partition") { v.partition { |x| x } }
end
