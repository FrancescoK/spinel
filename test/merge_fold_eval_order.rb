LOG = []
def rec(tag, h) = (LOG << tag; h)
def ev(o, m, *a) = o.send(m, *a)
def pick(i) = [{a: 1}, nil, "s"][i]
def maybe(tag, h, bad) = (LOG << tag; raise ArgumentError, "boom" if bad; h)

p pick(0).merge(rec(:x, {b: 2}), rec(:y, {c: 3}))
p LOG
LOG.clear
p ev(pick(0), :merge, rec(:x, {b: 2}), rec(:y, {c: 3}), rec(:z, {d: 4}))
p LOG
LOG.clear
begin
  pick(1).merge(rec(:x, {b: 2}), rec(:y, {c: 3}))
rescue NoMethodError => e
  p e.class
end
p LOG
LOG.clear
begin
  ev(pick(1), :merge, rec(:x, {b: 2}), rec(:y, {c: 3}), rec(:z, {d: 4}))
rescue NoMethodError => e
  p e.class
end
p LOG
LOG.clear
begin
  pick(0).merge(rec(:x, {b: 2}), maybe(:y, {c: 3}, true), rec(:z, {d: 4}))
rescue ArgumentError => e
  p e.message
end
p LOG
LOG.clear
p pick(0).merge(rec(:x, {a: 9}), rec(:y, {a: 10}))
p LOG
