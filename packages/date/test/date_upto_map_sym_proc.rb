# A lone `&:sym` block over an Enumerator that yields one value at a time
# (Date#upto, Date#step) receives the yielded Date, not an Array around it.
require "date"

d = Date.new(2024, 1, 1)
p d.upto(Date.new(2024, 1, 3)).map(&:to_s)
p d.step(Date.new(2024, 1, 5), 2).map(&:jd)
p d.downto(Date.new(2023, 12, 30)).map(&:day)
p d.upto(Date.new(2024, 1, 2)).map { |x| x.to_s }
p d.upto(Date.new(2024, 1, 2)).map { |*r| r.length }
