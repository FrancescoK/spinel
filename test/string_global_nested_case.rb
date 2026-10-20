# A shared String written to a global through `case` expressions nested in
# parentheses six deep, then changed in place through the global. The arms
# were read for a bang or a String Range's endpoint to a depth of 16, and
# each parenthesis, statement list and `else` cost a level.
def t1
  a = +"a"
  b = +"b"
  c = +"c"
  k = ARGV.size + 6
  $g = (case k when 6 then a else (case k when 5 then c else (case k when 4 then b else (case k when 3 then a else (case k when 2 then c else (case k when 1 then b else c end) end) end) end) end) end)
  $g << "!"
  p a, b, c, $g
end

t1
