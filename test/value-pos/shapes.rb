# One method per value-position shape. `spinel --dump-value-positions` lists
# the positions each body's value can come from; the expected file beside this
# one is that output (make value-pos-test). It is the unit test of
# src/value_pos.c and of tools/value_edges.yml: a shape the iterator misses, or
# reads in the wrong order or under the wrong parent, changes a line. The
# program is only parsed; test/value_pos_shapes.rb runs the same shapes.

def if_else(a)
  if a then 1 else 2 end
end

def if_no_else(a)
  if a then 1 end
end

def if_empty_then(a)
  if a then else 2 end
end

def ternary(a)
  a ? 1 : 2
end

def unless_else(a)
  unless a then 1 else 2 end
end

def unless_no_else(a)
  unless a then 1 end
end

def elsif_else(a)
  if a == 0
    0
  elsif a == 1
    1
  else
    2
  end
end

def elsif_no_else(a)
  if a == 0
    0
  elsif a == 1
    1
  end
end

def elsif_20(a)
  if a == 0
    0
  elsif a == 1
    1
  elsif a == 2
    2
  elsif a == 3
    3
  elsif a == 4
    4
  elsif a == 5
    5
  elsif a == 6
    6
  elsif a == 7
    7
  elsif a == 8
    8
  elsif a == 9
    9
  elsif a == 10
    10
  elsif a == 11
    11
  elsif a == 12
    12
  elsif a == 13
    13
  elsif a == 14
    14
  elsif a == 15
    15
  elsif a == 16
    16
  elsif a == 17
    17
  elsif a == 18
    18
  elsif a == 19
    19
  else
    20
  end
end

def case_when(a)
  case a
  when 0 then 0
  when 1, 2 then 1
  else 2
  end
end

def case_no_else(a)
  case a
  when 0 then 0
  when 1 then 1
  end
end

def case_in_else(a)
  case a
  in 0 then 0
  in 1 | 2 then 1
  else 2
  end
end

def case_in_no_else(a)
  case a
  in 0 then 0
  in 1 then 1
  end
end

def begin_plain
  begin
    1
  end
end

def begin_empty
  begin
  end
end

def begin_rescue(a)
  begin
    a.foo
  rescue ArgumentError
    1
  rescue TypeError => e
    2
  end
end

def begin_rescue_else(a)
  begin
    a.foo
  rescue ArgumentError
    1
  else
    2
  end
end

def begin_ensure(a)
  begin
    a.foo
  rescue ArgumentError
    1
  ensure
    3
  end
end

def begin_ensure_only(a)
  begin
    a.foo
  ensure
    3
  end
end

def begin_rescue_empty_body
  begin
  rescue ArgumentError
    1
  end
end

def rescue_modifier(a)
  a.foo rescue 1
end

def rescue_modifier_arms(a)
  if a then a.foo rescue 1 else 2 end
end

def and_op(a, b)
  a && b
end

def or_op(a, b)
  a || b
end

def or_chain(a, b, c)
  a || b || c
end

def mixed_logic(a, b, c)
  a && b || c
end

def paren_empty
  ()
end

def paren_one(a)
  (a)
end

def paren_several(a)
  (a; 1; 2)
end

def paren_nested(a)
  ((a; (1)))
end

def paren_in_arms(a)
  if a then (a; 1) else ((2)) end
end

def empty_body
end

def return_value(a)
  return 1 if a
  2
end

def return_bare(a)
  return if a
  2
end

def return_bare_tail
  return
end

def return_several(a)
  return 1, 2
end

def return_splat(a)
  return *a
end

def return_tail(a)
  return 1
end

def return_in_arm(a)
  if a
    return 1
  else
    2
  end
end

def next_and_break(a)
  a.each do |x|
    next 1 if x
    break 2 if x.nil?
  end
end

def next_tail
  [1].map { |x| next x }
end

def block_value
  [1].map { |x| x + 1 }
end

def write_local(a)
  x = if a then 1 else 2 end
end

def write_ivar(a)
  @v = a ? 1 : 2
end

def or_write(a)
  x ||= (a ? 1 : 2)
end

def and_write(a)
  x = 1
  x &&= a
end

def operator_write(a)
  x = 1
  x += a
end

def attr_write(a)
  a.foo = 1
end

def index_or_write(a)
  a[0] ||= 1
end

def multi_write(a)
  x, y = a, 1
end

def write_nested(a)
  x = (y = a ? 1 : 2)
end

def many_shapes(a, b)
  if a
    case b
    when 1 then (a; begin; b; rescue; 2; end)
    else a && b || (b rescue 3)
    end
  else
    x = b
  end
end

def string_interpolation(a)
  "#{a}"
end

def call_with_block(a)
  a.map { |x| if x then 1 else 2 end }
end

def lambda_value(a)
  -> { a }
end

def while_value(a)
  while a
    1
  end
end

def defined_value(a)
  defined?(a)
end

Top = ARGV.empty? ? 1 : 2
