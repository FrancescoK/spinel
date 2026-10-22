# sort with a block on an index Enumerator (each_with_index, each.with_index,
# map.with_index) compares two of its [element, index] pairs. It was refused
# at compile time: the two-param chain codegen, which reads a block as
# |element, index|, has no arm for it. The aws-sigv4 gem sorts query
# parameters this way, with the index as the tiebreak. The array is routed
# through a method so it is not constant-folded at the call site.

def params
  ["b=2", "a=1", "a=0", "a=1", "c"]
end

p params.each.with_index.sort { |a, b| a <=> b }
p params.each_with_index.sort { |a, b| b <=> a }
p params.map.with_index.sort { |a, b| a <=> b }
p params.each.with_index(1).sort { |a, b| a <=> b }
p params.each.with_index.sort { |a, b| a[1] <=> b[1] }.map(&:last)

# the gem's normalized_querystring: a duplicate name sorts by value, and a
# duplicate pair keeps its order through the index
def normalized(params)
  params.each.with_index.sort do |a, b|
    a, a_offset = a
    b, b_offset = b
    a_name, a_value = a.split('=')
    b_name, b_value = b.split('=')
    if a_name == b_name
      if a_value == b_value
        a_offset <=> b_offset
      else
        a_value <=> b_value
      end
    else
      a_name <=> b_name
    end
  end.map(&:first).join('&')
end

puts normalized(params)
