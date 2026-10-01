# Fiber storage is keyed by Symbol, and CRuby takes a String key as its
# Symbol and raises TypeError for any other key. The Fiber[] and Fiber[]=
# arms passed the key into an sp_sym slot whatever its type: a String or a
# boxed key gave invalid C, and Fiber[12] read nil. A key that is not
# statically a Symbol now goes through the conversion Thread#[] keys use.
p Fiber.new { Fiber["key"] = 42; Fiber[:key] }.resume
p Fiber.new { Fiber[:key] = 43; Fiber["key"] }.resume
k = +"dyn"
Fiber[k] = 1
p Fiber[:dyn], Fiber["dyn"]
[Object.new, 12, nil].each do |key|
  begin
    Fiber[key]
  rescue TypeError => e
    p e.message.sub(/0x\h+/, "XX")
  end
end
begin
  Fiber[12] = 44
rescue TypeError => e
  p e.message
end
keys = [:a, "b", 3]
keys.each do |key|
  begin
    Fiber[key] = key.to_s
    p Fiber[key]
  rescue TypeError => e
    p e.message
  end
end
