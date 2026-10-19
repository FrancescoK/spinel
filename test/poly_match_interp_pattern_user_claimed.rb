# A boxed receiver's match with an interpolated pattern, where a program
# class answers match too, goes through the boxed dispatch: the String arm
# took the call, so a receiver of that class raised TypeError (no implicit
# conversion into String) instead of running its own match.
class Completion
  def match(key)
    "completion #{key.source}"
  end
end

def rate(out, key)
  m = out.match(/key:'#{Regexp.escape(key)}'\s+value:'(\d+)'/)
  m && m[1].to_i
end

def find(x, n) = x.match(/id (#{n})/)

outs = ["key:'clock.rate' value:'48000'", 1]
p rate(outs[0], "clock.rate")
p rate(outs[0], "clock.quantum")
both = [Completion.new, "id 7"]
p find(both[0], 7)
p find(both[1], 7)[1]
p find(both[1], 8)
