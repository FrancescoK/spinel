# spinel: share
# A Hash's String read and handed to a method a poly receiver answers with,
# which appends to it, is the String the Hash holds: the append shows through
# the Hash, as it does for a receiver of one class (#8233).
class MutatingWriter
  def []=(key, value)
    value << "!"
  end
end

class Bang
  def add(v) = v << "!"
end

class Query
  def add(v) = v << "?"
end

def target(custom)
  custom ? MutatingWriter.new : {}
end

def copy(custom)
  destination = target(custom)
  source = { "name" => +"Ada" }
  destination["name"] = source["name"]
  puts source["name"]
end

copy(false)
copy(true)

def pick(f) = f ? Bang.new : Query.new
h = { "name" => +"Ada" }
pick(true).add(h["name"])
pick(false).add(h["name"])
puts h["name"]
