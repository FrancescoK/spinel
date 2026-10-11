# A local written from a call on itself, `t = t.alias(name)`, whose earlier
# write in node order is still untyped. A read ahead of the local's settling
# write carries the previous round's type, but only a concrete one: Table was
# carried, alias answered a TableAlias and the local widened to poly; poly
# was not carried, the read answered UNKNOWN, the write dropped out and the
# local narrowed back to Table. Every other round, to the cap.
class Table
  def initialize(name) = @name = name
  def name = @name
  def alias(n) = TableAlias.new(self, n)
end

class TableAlias
  def initialize(t, n)
    @t = t
    @n = n
  end
  def name = @n
end

def lookup(name) = nil

def table_for(name)
  k = lookup(name)
  if k
    t = k.table
    t = t.alias(name) if t.name != name
  else
    t = Table.new(name)
  end
  t.name
end

puts table_for("posts")
