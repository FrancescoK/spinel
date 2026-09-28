# `when 0..0.05` -- an Integer begin with a fractional Float end -- matches a
# Float the way CRuby's Range#=== does. The integer range representation
# truncated both the end (to 0) and the tested value, so 0.2 matched 0..0.05.
def bucket(d)
  case d
  when 0..0.05 then "low"
  when 0.05..0.15 then "normal"
  when 0.15..0.3 then "high"
  else "very_high"
  end
end
p bucket(0.2), bucket(0.03), bucket(0.1), bucket(0), bucket(0.5)
p (1..5.5).to_a, (1..5.5).sum
