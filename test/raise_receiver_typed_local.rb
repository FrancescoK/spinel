# A raise used as a call's receiver (`raise("...").first`), its value
# assigned to a local another read types (a Hash here), compiles and raises:
# the value never reaches the local, which a translator that stubs a missing
# library as `raise("... is not shipped")` keeps calling on (#9879).
def check(token)
  begin
    payload = raise("codec is not shipped on this target").first
    puts "jti" if payload["jti"].to_s.length > 0
  rescue StandardError => e
    puts "rescued: " + e.message
  end
end
check("t")

def count
  n = raise(ArgumentError, "no count").size
  n + 1
rescue ArgumentError => e
  e.message
end
p count

def name_of
  s = raise("no name").to_s
  s.upcase
rescue => e
  e.class
end
p name_of
