# spinel: gc-minor
# spinel: share
# Random defaults read the receiver with literal and forwarded blocks.
class Random
  def base = 8
  def defaults(a = base, key: base + 1)
    yield(a.to_s, key.to_s)
  end
end
r = Random.new(1)
p r.defaults { |x, y| [x, y] }
def forwarded_defaults(receiver, &)
  receiver.defaults(*[], **nil, &)
end
p forwarded_defaults(r) { |x, y| [x, y] }
p r.defaults(1, key: 2) { |x, y| [x, y] }
