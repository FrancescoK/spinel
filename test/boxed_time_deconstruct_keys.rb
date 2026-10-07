# A Time read out of a mixed Array matches a hash pattern and answers
# deconstruct_keys, as a typed Time does; and a Time pattern has CRuby's
# keys only (no :mon or :mday).
t = Time.at(1700000000, 250, :millisecond).utc
b = [t, 1][0]
case b
in {year: 2023, month:, day:}
  p [month, day]
else
  p :no
end
case b
in {hour: 22, min:, zone:}
  p [min, zone]
end
p b.deconstruct_keys(nil).keys
p b.deconstruct_keys([:year, :hour])
p b.deconstruct_keys([:foo, :year])
p b.deconstruct_keys(["year", 1])
p b.deconstruct_keys([])
p b.deconstruct_keys([:subsec])
begin
  b.deconstruct_keys(:year)
rescue TypeError => e
  p e.message
end
[t, b].each do |x|
  case x
  in {mon: 11}
    p :mon
  in {mday: 14}
    p :mday
  in {wday:, yday:}
    p [wday, yday]
  end
end
p t.deconstruct_keys(nil).keys == b.deconstruct_keys(nil).keys
h = [{year: 1}, 2][0]
case h
in {year:}
  p year
end
