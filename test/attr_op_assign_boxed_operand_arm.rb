# `s.pos += r` on an attribute with no writer of its own, where `r` is held
# boxed (an Integer, a Float, a String or nil), as the last statement of an
# arm of an `if`, a `case` or a begin, in parentheses, in a rescue modifier
# and as an operand of `&&`, before the last statement of its method. The
# statement is written as a read and a write call, which keeps the attribute
# boxed; a plain store would give an Integer slot a Float's truncation (2
# for 2.5), so an_value_dropped's reading of these shapes as thrown away
# does not decide it: the desugar keeps the node's own statement list.
class S
  attr_accessor :pos

  def initialize
    @pos = 0
  end
end

def in_if(s, r, c)
  if c
    s.pos += r
  end
  nil
end

def in_case(s, r, c)
  case c
  when 1
    s.pos += r
  else
    s.pos += r
  end
  nil
end

def in_begin(s, r)
  begin
    s.pos += r
  rescue ZeroDivisionError
    nil
  end
  nil
end

def in_parens(s, r)
  (s.pos += r)
  nil
end

def in_modifier(s, r)
  s.pos += r rescue nil
  nil
end

def in_logic(s, r, c)
  c && s.pos += r
  nil
end

vals = [1, 2.5, "x", nil]
forms = [
  ->(s, r) { in_if(s, r, true) },
  ->(s, r) { in_case(s, r, 2) },
  ->(s, r) { in_begin(s, r) },
  ->(s, r) { in_parens(s, r) },
  ->(s, r) { in_modifier(s, r) },
  ->(s, r) { in_logic(s, r, true) }
]
forms.each do |f|
  s = S.new
  vals.each do |r|
    begin
      f.call(s, r)
      p s.pos
    rescue => e
      p e.class
    end
  end
end
