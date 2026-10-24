# spinel: rbs-seed-run
# A boxed value reaches a parameter the seed types Time: a Time passes, and
# a value of another class raises TypeError at the call, where it was read
# as a Time and crashed (#10154). CRuby, which reads no seed, runs
# the method on the Integer; the signature is the program's contract here.
class TimeSeedSchedule
  def self.schedule(job, at, payload = nil)
    at.to_i
  end
end

def try_schedule(v)
  p TimeSeedSchedule.schedule(Object, v)
rescue TypeError => e
  puts "TypeError: #{e.message}"
end

try_schedule([1792175700, "x"][0])
try_schedule([Time.at(5), 1][0])
try_schedule(["2026", 1][0])
