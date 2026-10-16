# spinel: gc-minor
# A String literal key on a Hash read stays the String when an earlier round
# marked it as an argument a rest parameter keeps: the receiver was a boxed
# value then, a user [] took the keys, and settled to a Hash after.
class Bag
  def initialize
    @items = []
  end

  def [](*keys)
    keys.each { |k| @items << k }
    @items.each { |s| s << "!" }
    @items.size.to_s
  end
end

def get(env)
  (env["REQUEST_METHOD"] || "GET").to_s
end

def fetch_all(env)
  [env["HTTP_HOST"], env["PORT"], env["MISSING"]]
end

def request(host, method)
  env = { "HTTP_HOST" => host, "PORT" => 80 }
  env["REQUEST_METHOD"] = method
  puts fetch_all(env).inspect
  env.delete("REQUEST_METHOD")
  env.key?("HTTP_HOST")
  get(env)
end

puts request("h", "POST")
puts request("example.org", "PUT")
puts Bag.new[+"a", +"b"]
