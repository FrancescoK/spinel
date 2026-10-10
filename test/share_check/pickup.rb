# The handle a call publishes is taken after the call ran: an argument that
# ran first must not move the pickup in front of the call.
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
