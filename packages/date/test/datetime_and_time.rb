# spinel: share
# DateTime with offsets, and Time#to_date. json_schemer validates
# `format: date-time` with DateTime.rfc3339 and new_offset.
require "date"

dt = DateTime.rfc3339("2024-05-06T23:59:60+00:00")
p dt.new_offset.strftime("%H:%M")
dt = DateTime.new(2024, 5, 6, 13, 30, 15, "+09:00")
p dt.to_s, dt.hour, dt.minute, dt.second, dt.offset, dt.zone
p dt.new_offset(0).to_s, dt.new_offset("-03:00").iso8601
p (dt + Rational(1, 24)).to_s
p dt.to_date.to_s, dt.strftime("%Y-%m-%dT%H:%M:%S%:z")
t = Time.utc(2026, 10, 15, 13, 0, 0)
p t.to_date.to_s, t.to_date.class, (t.to_date - 3).iso8601
p t.to_datetime.to_s
p DateTime.iso8601("2024-05-06T10:20:30Z").to_s
