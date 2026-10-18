# spinel: share
# Civil dates: construction, the calendar fields, arithmetic and comparison,
# as CRuby's date answers them.
require "date"

d = Date.new(2024, 2, 28)
p d.to_s, d.year, d.month, d.day, d.wday, d.yday, d.cwday, d.cweek
p d.leap?, Date.new(2023, 1, 1).leap?
p (d + 1).to_s, (d + 2).to_s, (d - 60).to_s
p (d >> 1).to_s, (d << 2).to_s, d.next_month(12).to_s, d.prev_day.to_s
p (Date.new(2024, 3, 10) - d).to_i
p d < Date.new(2024, 3, 1), d == Date.new(2024, 2, 28), d <=> Date.new(2020, 1, 1)
p Date.valid_date?(2023, 2, 29), Date.valid_date?(2024, 2, 29)
p Date.new(2024, -1, -1).to_s
p d.jd, Date.jd(2460369).to_s
p d.mjd, d.ajd
h = Hash.new(0)
[Date.new(2024, 1, 1), Date.new(2024, 1, 1), Date.new(2024, 1, 2)].each { |x| h[x] += 1 }
p h.size, h[Date.new(2024, 1, 1)]
p Date.new(2024, 1, 1).step(Date.new(2024, 1, 10), 3).map { |x| x.to_s }
p d.inspect.start_with?("#<Date: 2024-02-28")
begin
  Date.new(2023, 2, 30)
rescue Date::Error => e
  p e.class, e.message
end
