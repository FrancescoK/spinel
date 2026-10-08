# A child's --rbs ivar pin under a PARENT-class method that writes the same
# ivar from an untyped source: the struct layouts must stay cast-compatible
# (the parent writes through a (Parent*) cast of the child), so the pin
# yields with a warning instead of splitting the layouts -- which read
# garbage strings and 0 ints, or segfaulted (#1871).
# spinel: rbs-seed-check
class Base
  def assign(row)
    @id = row["id"]
    @body = row["body"]
  end
end

class Thing < Base
  def id
    @id
  end

  def body
    @body
  end
end

t = Thing.new
t.assign({ "id" => 1, "body" => "hello world" })
puts t.id
puts t.body
