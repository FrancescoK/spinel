# Every method below answers a different value from each arm of one
# value-position shape: an if or unless, an elsif chain (one of 20 arms), a
# case with when and with in, a begin with rescue, else and ensure, the rescue
# modifier, && and ||, parentheses of one statement and of several, the values
# a return, next and break hand out, and the writes whose value is the value
# written. The program prints what each answers for every arm, so a walker that
# misses a shape shows as a wrong number. The structural twin of this file is
# test/value-pos/shapes.rb, whose --dump-value-positions output lists the same
# shapes' positions.

def show(name, arg, result)
  puts "#{name}(#{arg}) = #{result.inspect}"
end

def if_else(a)
  if a == 0 then 1 else 2 end
end

def if_no_else(a)
  if a == 0 then 1 end
end

def if_empty_then(a)
  if a == 0 then else 2 end
end

def unless_else(a)
  unless a == 0 then 1 else 2 end
end

def unless_no_else(a)
  unless a == 0 then 1 end
end

def elsif_chain(a)
  if a == 0
    10
  elsif a == 1
    11
  elsif a == 2
    12
  else
    13
  end
end

def elsif_no_else(a)
  if a == 0
    10
  elsif a == 1
    11
  end
end

def elsif20(a)
  if a == 0
    100
  elsif a == 1
    101
  elsif a == 2
    102
  elsif a == 3
    103
  elsif a == 4
    104
  elsif a == 5
    105
  elsif a == 6
    106
  elsif a == 7
    107
  elsif a == 8
    108
  elsif a == 9
    109
  elsif a == 10
    110
  elsif a == 11
    111
  elsif a == 12
    112
  elsif a == 13
    113
  elsif a == 14
    114
  elsif a == 15
    115
  elsif a == 16
    116
  elsif a == 17
    117
  elsif a == 18
    118
  elsif a == 19
    119
  else
    999
  end
end

def case_when(a)
  case a
  when 0 then 20
  when 1, 2 then 21
  when 3
    22
  else
    23
  end
end

def case_no_else(a)
  case a
  when 0 then 20
  when 1 then 21
  end
end

def case_in(a)
  case a
  in 0 then 30
  in Integer => n if n > 5 then 31
  in 1 | 2 then 32
  else 33
  end
end

def case_in_no_else(a)
  case a
  in 0 then 40
  in 1 then 41
  end
end

def begin_rescue(a)
  begin
    raise ArgumentError, "a" if a == 1
    raise TypeError, "t" if a == 2
    50
  rescue ArgumentError
    51
  rescue TypeError
    52
  end
end

def begin_rescue_else(a)
  begin
    raise ArgumentError, "a" if a == 1
    60
  rescue ArgumentError
    61
  else
    62
  end
end

def begin_ensure(a)
  begin
    raise ArgumentError, "a" if a == 1
    70
  rescue ArgumentError
    71
  ensure
    72
  end
end

def begin_plain
  begin
    80
  end
end

def begin_empty_rescue(a)
  begin
    raise ArgumentError, "a" if a == 1
  rescue ArgumentError
  end
end

def rescue_modifier(a)
  (raise ArgumentError, "a" if a == 1; 90) rescue 91
end

def rescue_modifier_nested(a)
  if a == 0 then (raise "x") rescue 92 else 93 end
end

def and_right(a)
  (a == 0 ? nil : a) && 100
end

def or_both(a)
  (a == 0 ? nil : a) || 110
end

def or_chain(a)
  (a == 0 ? nil : a) || (a == 1 ? nil : 120) || 121
end

def paren_one(a)
  (a == 0 ? 130 : 131)
end

def paren_several(a)
  (a + 1; a == 0 ? 140 : 141)
end

def paren_in_arm(a)
  if a == 0
    (a + 1; 150)
  elsif a == 1
    (151)
  else
    ((a + 2; 152))
  end
end

def return_value(a)
  return 160 if a == 0
  if a == 1
    return 161
  end
  162
end

def return_in_arm(a)
  if a == 0
    return 170
  else
    171
  end
end

def next_values
  [1, 2, 3].map do |x|
    next 180 if x == 1
    if x == 2
      next 181
    end
    182
  end
end

def break_value
  [1, 2, 3].each do |x|
    break 190 if x == 2
  end
end

def loop_break
  i = 0
  loop do
    i += 1
    break i * 10 if i > 3
  end
end

def write_local(a)
  x = if a == 0 then 200 else 201 end
  x
end

def write_value(a)
  x = (a == 0 ? 210 : 211)
end

def or_write(a)
  x = nil
  x ||= (a == 0 ? 220 : 221)
end

def and_write(a)
  x = 1
  x &&= (a == 0 ? 230 : 231)
end

def nested_write(a)
  y = 0
  x = (y = a == 0 ? 240 : 241)
end

def ivar_write(a)
  @v = a == 0 ? 250 : 251
end

# the old value is the answer of an or-write when it is truthy, of an
# and-write when it is falsy
def orw(x)
  (x ||= 7)
end

def andw(x)
  (x &&= 8)
end

def idxor(h)
  (h[:k] ||= 3)
end

def idxand(h)
  (h[:k] &&= 4)
end

def ivor(v)
  @i = v
  (@i ||= 5)
end

def ivand(v)
  @i = v
  (@i &&= 6)
end

def gvor(v)
  $g = v
  ($g ||= 9)
end

class Cell
  attr_accessor :a
end

def callor(v)
  c = Cell.new
  c.a = v
  (c.a ||= 11)
end

def calland(v)
  c = Cell.new
  c.a = v
  (c.a &&= 12)
end


[0, 1, 2].each do |a|
  show("if_else", a, if_else(a))
  show("if_no_else", a, if_no_else(a))
  show("if_empty_then", a, if_empty_then(a))
  show("unless_else", a, unless_else(a))
  show("unless_no_else", a, unless_no_else(a))
  show("elsif_chain", a, elsif_chain(a))
  show("elsif_no_else", a, elsif_no_else(a))
end
[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20].each do |a|
  show("elsif20", a, elsif20(a))
end
[0, 1, 2, 3, 4].each do |a|
  show("case_when", a, case_when(a))
  show("case_no_else", a, case_no_else(a))
end
[0, 1, 2, 7].each do |a|
  show("case_in", a, case_in(a))
end
[0, 1].each do |a|
  show("case_in_no_else", a, case_in_no_else(a))
end
begin
  case_in_no_else(2)
  puts "case_in_no_else(2) answered"
rescue NoMatchingPatternError
  puts "case_in_no_else(2) raised NoMatchingPatternError"
end
[0, 1, 2].each do |a|
  show("begin_rescue", a, begin_rescue(a))
end
[0, 1].each do |a|
  show("begin_rescue_else", a, begin_rescue_else(a))
  show("begin_ensure", a, begin_ensure(a))
  show("begin_empty_rescue", a, begin_empty_rescue(a))
  show("rescue_modifier", a, rescue_modifier(a))
  show("rescue_modifier_nested", a, rescue_modifier_nested(a))
end
show("begin_plain", "", begin_plain)
[0, 1, 2].each do |a|
  show("and_right", a, and_right(a))
  show("or_both", a, or_both(a))
  show("or_chain", a, or_chain(a))
  show("paren_one", a, paren_one(a))
  show("paren_several", a, paren_several(a))
  show("paren_in_arm", a, paren_in_arm(a))
  show("return_value", a, return_value(a))
  show("return_in_arm", a, return_in_arm(a))
  show("write_local", a, write_local(a))
  show("write_value", a, write_value(a))
  show("or_write", a, or_write(a))
  show("and_write", a, and_write(a))
  show("nested_write", a, nested_write(a))
  show("ivar_write", a, ivar_write(a))
end
show("next_values", "", next_values)
show("break_value", "", break_value)
show("loop_break", "", loop_break)
show("orw", 5, orw(5))
show("orw", nil, orw(nil))
show("andw", nil, andw(nil))
show("andw", false, andw(false))
show("andw", 3, andw(3))
show("idxor", 9, idxor({k: 9}))
show("idxor", "none", idxor({}))
show("idxand", 9, idxand({k: 9}))
show("idxand", "none", idxand({}))
show("ivor", 2, ivor(2))
show("ivor", nil, ivor(nil))
show("ivand", nil, ivand(nil))
show("ivand", 2, ivand(2))
show("gvor", 2, gvor(2))
show("gvor", nil, gvor(nil))
show("callor", 2, callor(2))
show("callor", nil, callor(nil))
show("calland", nil, calland(nil))
show("calland", 2, calland(2))
