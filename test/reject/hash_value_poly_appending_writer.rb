# A String a Hash#each yields into a poly []= whose user writer appends to
# it is refused, as with a static writer: the default build would hand the
# writer a copy. The C did not build (#8216).
class MutatingWriter
  def []=(key, value)
    value << "!"
  end
end

def target(custom)
  custom ? MutatingWriter.new : {}
end

def copy(custom)
  destination = target(custom)
  source = { "name" => +"Ada" }
  source.each do |key, value|
    destination[key] = value
  end
  puts source["name"]
end

copy(false)
copy(true)
