# A class method the program defines on Time changes a Time someone holds
# (`zone` on $last): a Time is a reference, so the change reaches $last, as
# in CRuby. (From #9986, where it was refused.)
class Time
  def self.last = $last
end

def zone(t) = t.localtime(3600)

$last = Time.utc(2026, 10, 15, 1, 0, 0)
zone(Time.last)
p $last.utc_offset
