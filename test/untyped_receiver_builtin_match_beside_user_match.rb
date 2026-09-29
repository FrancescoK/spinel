# A user class defines `match`, but the program never builds one, so a
# `match` call on a receiver nothing types takes the builtin String/Regexp
# arm in codegen. The analyzer counted the user method and typed the call
# poly, and the builtin's bare MatchData pointer went into that poly slot:
# the C did not compile. Here Dispatcher#call is dead, and the program has to
# build all the same.
class Route
  def match(path) = path == "/" ? {} : nil
end

class Dispatcher
  def initialize(routes) = @routes = routes

  def call(path)
    @routes.each do |route|
      params = route.match(path)
      return params unless params.nil?
    end
    nil
  end
end

# The same call reached with Strings still answers the builtin MatchData.
class Scanner
  def initialize(items) = @items = items

  def first_hit(re)
    @items.each do |item|
      m = item.match(re)
      return m unless m.nil?
    end
    nil
  end
end

p Scanner.new(["/a", "/b"]).first_hit(/b/)
puts "Dispatcher is never used here"
