require "time"
ENV["TZ"] = "UTC"
now = Time.utc(2026, 1, 15, 12, 0, 0)
p Time.strptime("22/10/2026 13:45", "%d/%m/%Y %H:%M")
p Time.strptime("2026-03-04 10:20 +0900", "%Y-%m-%d %H:%M %z")
p Time.strptime("1700000000", "%s")
p Time.strptime("1700000000 +0900", "%s %z")
p Time.strptime("10:20:30.5", "%H:%M:%S.%N", now).nsec
p Time.strptime("2026 063", "%Y %j")
p Time.strptime("Wed Mar 04 2026", "%a %b %d %Y")
p Time.strptime("10:20", "%H:%M", now)
begin; Time.strptime("x", "%Y"); rescue ArgumentError => e; p e.message; end
