# The Enumerable methods written in Ruby (min_by, max_by, sort_by, ...),
# copied per call, over an Array literal of Integers and nils: the nil
# element reaches the block as nil. Under --int-overflow=promote the
# literal is boxed after the copy's parameter was typed from it, and the
# nil read as 0.
def ni(x) = x > 0 ? x : nil

p [ni(3), ni(-3)].min_by { |e| e || 99 }
p [ni(3), ni(-3)].max_by { |e| e || -99 }
p [ni(-3), ni(3)].min_by { |e| e ? -e : 99 }
p [ni(2), ni(-1), ni(5)].sort_by { |e| e || 0 }
p [ni(2), ni(-1), ni(5)].min_by(2) { |e| e || 0 }
p [ni(2), ni(-1)].each_with_index.map { |e, i| [e, i] }
p [ni(4), ni(-4)].count(&:nil?)
p [ni(4), ni(-4)].partition { |e| e.nil? }
