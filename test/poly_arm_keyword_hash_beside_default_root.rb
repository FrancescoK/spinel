# spinel: gc-stress
class Probe
  def match(object, query = {}, event_args = [])
    query.key?(:invalid) ? [query[:invalid], event_args.size] : :none
  end
end

class Other
  def match(object, query = {}, event_args = []) = :other
end

pick = [Probe.new, Other.new, 1]
r = nil
200.times { |i| r = pick[i % 2].match(Object.new, invalid: i) }
p r
p pick[0].match(Object.new, invalid: true)
p pick[1].match(Object.new, invalid: true)
