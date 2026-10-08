# An --rbs signature makes an ivar's slot concrete while observed dataflow
# makes the value poly, and the attr WRITER path is where the two meet. The
# local-assignment path narrows a poly rhs into a concrete slot; the writer
# only knew how to coerce the gate's raising token, so the sp_RbVal was
# assigned raw into a const char * and the C build stopped (#4093).
# spinel: rbs-seed-check
class Cand
  attr_accessor :id

  def initialize(id)
    self.id = id
  end

  def to_s
    id
  end

  def to_i
    id
  end
end

class Req
  attr_accessor :verb
  attr_accessor :count
end

def build(v)
  r = Req.new
  r.verb = (v || "GET").to_s
  r.count = (v || 2).to_i
  r
end

r = build(nil)
p r.verb
p r.count
p build("POST").verb
p build(Cand.new("abc")).verb
p build(Cand.new(7)).count
