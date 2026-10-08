# A returned shared field keeps its identity beside fresh, nil and raising
# arms. A fresh arm clears any handle its own evaluation published.
class RequestPath
  attr_reader :path
  def initialize
    @path = +"path"
  end

  def value(query)
    path = @path.empty? ? "/" : @path
    query ? "#{path}?query" : path
  end

  def alternate(mode)
    return @path if mode == 0
    return "#{@path}/fresh" if mode == 1
    return nil if mode == 2
    raise ArgumentError, "missing" if mode == 3
    "literal"
  end
end

class StoredPath
  attr_reader :path
  def initialize(source, query)
    @path = query.nil? ? source.value(false) : source.value(query)
  end
end

def append_path(value)
  value << "!"
  value
end

source = RequestPath.new
p append_path(source.value(true))
p source.path
stored = StoredPath.new(source, nil)
p stored.path.equal?(source.path)
p append_path(stored.path)
p source.path
p append_path(source.alternate(1))
p source.path
p source.alternate(0).equal?(source.path)
p source.alternate(2)
begin
  source.alternate(3)
rescue ArgumentError => e
  p e.message
end
begin
  append_path(source.alternate(4))
rescue FrozenError
  puts "frozen"
end
