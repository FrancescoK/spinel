# A begin or a catch read as a value is held until its expression reads it.
# The value waits in a temp ahead of the statement, and what an operand
# after it puts there (a second begin, a catch) runs before the expression
# reads the temp. Each line counts the values that came back as another
# object: a Struct's super, with and without keywords, two Strings and two
# Arrays added, an interpolation, a String Range, a receiver, and a catch
# on either side.
# spinel: gc-stress
def churn(n)
  i = 0
  x = nil
  while i < n
    x = ["c#{i}", "d#{i}"]
    i += 1
  end
  x
end
def name_of(i)
  churn(200)
  "n" + i.to_s
end
def tag_of(i)
  churn(200)
  "t" + i.to_s
end
def tags_of(i)
  churn(200)
  ["t" + i.to_s, "x"]
end
def span_of(i)
  a = name_of(i)
  b = tag_of(i)
  a..b
end
class Item
  attr_reader :v
  def initialize(v)
    @v = v
  end
end
def item_of(i)
  churn(200)
  Item.new("v" + i.to_s)
end

Pair = Struct.new(:name, :tags) do
  def initialize(i)
    super((begin; churn(50); name_of(i); end), (begin; tags_of(i); ensure; churn(10); end))
  end
end
Named = Struct.new(:name, :tags, keyword_init: true) do
  def initialize(i)
    super(name: (begin; name_of(i); rescue; "x"; end), tags: (begin; tags_of(i); ensure; churn(10); end))
  end
end

def count(rows)
  churn(2000)
  bad = 0
  rows.each_with_index { |r, i| bad += 1 unless yield(r, i) }
  bad
end

rows = []
300.times { |i| rows << Pair.new(i) }
p count(rows) { |r, i| r.name == "n#{i}" && r.tags == ["t#{i}", "x"] }

rows = []
300.times { |i| rows << Named.new(i) }
p count(rows) { |r, i| r.name == "n#{i}" && r.tags == ["t#{i}", "x"] }

rows = []
300.times { |i| rows << ((begin; name_of(i); rescue; "x"; end) + (begin; tag_of(i); rescue; "y"; end)) }
p count(rows) { |r, i| r == "n#{i}t#{i}" }

rows = []
300.times { |i| rows << ((begin; tags_of(i); rescue; ["q"]; end) + (begin; tags_of(i); ensure; churn(10); end)) }
p count(rows) { |r, i| r == ["t#{i}", "x", "t#{i}", "x"] }

rows = []
300.times { |i| rows << "#{begin; name_of(i); rescue; "x"; end}#{begin; tag_of(i); rescue; "y"; end}" }
p count(rows) { |r, i| r == "n#{i}t#{i}" }

rows = []
300.times { |i| rows << ((begin; span_of(i); rescue; ("a".."b"); end).first + (begin; tag_of(i); ensure; churn(10); end)) }
p count(rows) { |r, i| r == "n#{i}t#{i}" }

rows = []
300.times { |i| rows << ((begin; item_of(i); rescue; Item.new("x"); end).v + (begin; tag_of(i); ensure; churn(10); end)) }
p count(rows) { |r, i| r == "v#{i}t#{i}" }

rows = []
300.times { |i| rows << ((catch(:t) { throw :t, name_of(i) }) + (begin; tag_of(i); ensure; churn(10); end)) }
p count(rows) { |r, i| r == "n#{i}t#{i}" }

rows = []
300.times { |i| rows << ((begin; name_of(i); rescue; "x"; end) + (catch(:t) { throw :t, tag_of(i) })) }
p count(rows) { |r, i| r == "n#{i}t#{i}" }
