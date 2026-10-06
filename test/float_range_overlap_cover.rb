# A Float Range answers overlap? as an Integer Range does, and a boxed one
# covers a boxed Integer Range argument by its ends.
p (1.0..2.0).overlap?(1.5..3.0)
p (1.0..2.0).overlap?(3..4)
p (1.0...2.0).overlap?(2..3)
p (1.0..2.0).overlap?(2.0...2.0)
p (1.0..).overlap?(..0)
p (1.0..2.0).overlap?([(2..3), 1][0])
begin
  (1.0..2.0).overlap?(3)
rescue TypeError => e
  puts e.message
end
f = [(1.0..5.0), 1][0]
p f.cover?([(2..3), 1][0])
p f.cover?([(0..3), 1][0])
p f.cover?([2.5, 1][0])
p f.cover?([7, 1][0])
p f.include?([(2..3), 1][0])
