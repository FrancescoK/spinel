# Hash#select / #reject / #filter on a typed Hash take an Integer block
# value by Ruby's truthiness: 0 keeps the pair, nil drops it.
ages = { "ann" => 0, "bob" => 1, "cy" => 2 }
p ages.select { |k, v| v }
p ages.filter { |k, v| v }
p ages.reject { |k, v| v }

# nil from one pair, an Integer from the others
p ages.select { |k, v| v == 1 ? nil : v }
p ages.reject { |k, v| v == 1 ? nil : v }

# a bare `next` gives nil; `next v` gives the Integer
p ages.select { |k, v| next if v == 1; v }
p ages.reject { |k, v| next if v == 1; v }
p ages.select { |k, v| next v * 10 if v == 1 }

ids = { 10 => 0, 20 => 5 }
p ids.select { |k, v| v }
p ids.reject { |k, v| v }
