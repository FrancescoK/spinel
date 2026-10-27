# A fixed-offset Time (is_utc kind 2) renders its CIVIL fields shifted by
# utc_off. sp_time_vtm has always done that -- so #hour, #to_s and #inspect
# were right -- but strftime / iso8601 / xmlschema read the 3-state kind as a
# boolean and took the UTC branch, printing UTC clock fields under a %z that
# correctly said otherwise.

require "time"  # Time#iso8601 / #xmlschema are require-only stdlib

t = Time.at(1689676186).getlocal(-5 * 3600)

# the accessors that already routed through sp_time_vtm
p t.hour
p t.to_s

# strftime: every field directive, not just %z
p t.strftime("%Y-%m-%d %H:%M:%S %z")
p t.strftime("%H:%M")
p t.strftime("%a, %d %b %Y %H:%M:%S %z")  # RFC 2822, the RSS-feed shape
p t.strftime("%j")                        # day-of-year crosses the date line
p t.strftime("%s")                        # epoch stays zone-independent

# iso8601 / xmlschema: civil fields AND the zone suffix
p t.iso8601
p t.xmlschema
p t.iso8601(3)

# a date that rolls back over midnight under the offset
p Time.at(1689638400).getlocal(-5 * 3600).iso8601  # 2023-07-18T00:00:00Z

# east of Greenwich, and the whole thing again through Time.new's 7th argument
e = Time.at(1689676186).getlocal(9 * 3600)
p e.strftime("%Y-%m-%d %H:%M:%S %z")
p e.iso8601
p Time.new(2000, 1, 1, 12, 0, 0, "+09:00").iso8601

# a fixed-offset time has no zone NAME, so %Z is empty. (CRuby's Time#zone
# returns nil for this kind where spinel returns ""; making #zone nilable is a
# return-type change, not a formatter one, so it is left alone here.)
p t.strftime("%Z")

# the UTC and host-local kinds are unchanged
u = Time.utc(2026, 7, 16, 13, 45, 30)
p u.strftime("%Y-%m-%d %H:%M:%S %z")
p u.strftime("%Z")
p u.iso8601
p u.iso8601(6)
