# A bang on a call's answer, used as a value in a position that is only
# tested for nil: the emitter answers the receiver's handle, and the bytes
# the bang read and wrote back are no copy (the check reports nothing).
def pick(value, missing)
  return nil if missing
  value
end
s = +"ab"
results = []
[false, true].each do |missing|
  begin
    results << pick(s, missing).upcase!
  rescue NoMethodError => e
    p e.class
  end
end
p [results[0], results[0].equal?(s), s]
