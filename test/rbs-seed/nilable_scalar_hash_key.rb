# An `Integer?` / `Float?` seed keeps the unboxed kind and spells nil with the
# slot's reserved sentinel. Boxing that as an ordinary number made it a Hash
# key no literal nil could match -- while `.nil?`, `== nil` and `inspect` all
# still called it nil, so the miss was silent (#3493). The grouping shape at
# the end is where it was found: a nullable foreign key whose nil bucket the
# literal-nil lookup could not see.
# spinel: rbs-seed-check
class NkR
  def initialize(p)
    @p = p
  end

  def p_
    @p
  end
end

k = NkR.new(nil).p_
puts "nil?      #{k.nil?}"
puts "== nil    #{k == nil}"

h = {}
h[k] = "var"
puts "h[k]      #{h[k].inspect}"
puts "h[nil]    #{h[nil].inspect}"
puts "fetch     #{h.fetch(nil, '--').inspect}"
puts "key?      #{h.key?(nil)}"
puts "keys0nil? #{h.keys[0].nil?}"

g = {}
g[nil] = "literal"
puts "g[k]      #{g[k].inspect}"

m = { k => 1, nil => 2 }
puts "m.length  #{m.length}"

class NkF
  def initialize(v)
    @v = v
  end

  def val
    @v
  end
end

fk = NkF.new(nil).val
fh = {}
fh[fk] = "f"
puts "fh[nil]   #{fh[nil].inspect}"
puts "fkeys0    #{fh.keys[0].nil?}"

class NkRow
  def initialize(id, parent)
    @id = id
    @parent = parent
  end

  def id
    @id
  end

  def parent_id
    @parent
  end
end

rows = [NkRow.new(1, nil), NkRow.new(2, 1), NkRow.new(3, nil), NkRow.new(4, 2)]
parents = rows.group_by { |r| r.parent_id }
puts "groups    #{parents.length}"
puts "nil group #{parents[nil].map { |r| r.id }.inspect}"
puts "one group #{parents[1].map { |r| r.id }.inspect}"
