# A raising pattern arm has no value to assign, including an explicit
# return of the case expression and a side effect before the raise.
def pick(x)
  return case x
  in Integer then "ok"
  in String
    puts "raising"
    raise ArgumentError, "bad"
  else
    fail "other"
  end
end
p pick(1)
begin
  pick("x")
rescue ArgumentError => e
  p e.message
end
begin
  pick(false)
rescue RuntimeError => e
  p e.message
end

# Parentheses preserve divergence, including nested parentheses and fail.
def pick_parens(x)
  return case x
  in Integer then "ok"
  in String
    puts "raising in parentheses"
    ((raise ArgumentError, "parenthesized"))
  else
    (fail "other in parentheses")
  end
end
p pick_parens(1)
begin
  pick_parens("x")
rescue ArgumentError => e
  p e.message
end
begin
  pick_parens(false)
rescue RuntimeError => e
  p e.message
end
