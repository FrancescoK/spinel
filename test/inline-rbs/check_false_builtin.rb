# spinel: not-cruby -- a false inline annotation naming a builtin class aborts under -DSP_RBS_CHECK
class Clock
  #: (Time t) -> Integer
  def secs(t) = t.to_i
end

vals = [Time.at(5), "five"]
p Clock.new.secs(vals[0])
p Clock.new.secs(vals[1])
