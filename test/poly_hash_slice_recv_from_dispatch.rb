# A Hash that reaches `slice` as the answer of another call on a receiver
# known only at run time keeps Hash#slice beside a user slice(i, len = nil).
class Set2
  def initialize(items) = @items = items
  def slice(i, len = nil) = len ? Set2.new(@items[i, len]) : @items[i]
end

class Sub
  def initialize(id) = @id = id
  def attributes = { "id" => @id, "endpoint" => "e", "p256dh_key" => "p", "auth_key" => "a" }
end

class Other
  def attributes = [1, 2]
end

def newest(list) = list.last

p Set2.new([1, 2, 3]).slice(1)
subs = ARGV.empty? ? [Sub.new(1), Sub.new(2)] : [Other.new]
p newest(subs).attributes.slice("endpoint", "p256dh_key", "auth_key")
p newest(subs).attributes.slice("id")
p newest(subs).attributes.slice("endpoint", "auth_key")
