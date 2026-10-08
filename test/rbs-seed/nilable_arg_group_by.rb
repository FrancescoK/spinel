# A literal nil argument into an RBS-nilable Integer param must arrive as
# the nil sentinel, and group_by over that nilable key must file the
# nil-returning elements under the nil key.
# spinel: rbs-seed-check
class P
  attr_reader :k

  def initialize(k)
    @k = k
  end
end

class W
  def self.go(rows)
    h = rows.group_by { |r| r.k }
    roots = h[nil]
    roots.nil? ? 0 : roots.length
  end
end

rows = [P.new(1), P.new(nil), P.new(nil)]
puts W.go(rows)
h2 = rows.group_by { |r| r.k }
p h2.keys
p h2[1].length
