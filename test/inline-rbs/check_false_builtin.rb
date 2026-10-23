# spinel: not-cruby -- a false inline annotation naming a builtin class aborts under -DSP_RBS_CHECK
class Clock
  #: (Time t) -> Integer
  def secs(t) = t.to_i
end

# (a Range is boxed as an object too: the check compares the builtin class)
vals = [Time.at(5), (1..5)]
p Clock.new.secs(vals[0])
p Clock.new.secs(vals[1])
