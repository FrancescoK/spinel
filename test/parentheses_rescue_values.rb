# Parenthesized rescue arms keep each inline block's value and the nil join.
# spinel: gc-stress

def sequence_value
  r = (puts :yielded; yield) rescue (1..2)
  p r
end
sequence_value { nil }
sequence_value { 5 }
sequence_value { "s" }
sequence_value { false }
sequence_value { [1, 2] }
sequence_value { raise "no" }

def single_value
  r = (yield) rescue 7
  p r
end
single_value { nil }
single_value { 5 }
single_value { "s" }
single_value { false }
single_value { raise "no" }

p (() rescue (1..2))
p ((puts :nil_range; nil) rescue (1..2))
p (((nil)) rescue (1..2))
p ((raise "no") rescue (1..2))
p ((puts :d; nil) rescue "s")
p (() rescue "s")
p (nil rescue "s")
p ((raise "no") rescue "s")

def bare_value
  r = yield rescue 7
  p r
end
bare_value { nil }
bare_value { 5 }
bare_value { "s" }

def single_numeric
  r = (yield) rescue 7
  p r
end
single_numeric { nil }
single_numeric { 5 }
def sequence_numeric
  r = (puts :numeric; yield) rescue (1..2)
  p r
end
sequence_numeric { nil }
sequence_numeric { 5 }
