# `folder["devices"] << { ... }` on a receiver of more than one class reaches
# every class's `[]`. A Hash literal is no argument String#<< takes, so the
# Strings those classes store are not made shared handles; an append of a
# String through such an element still is seen.
class Jar
  def initialize = (@out = {})
  def [](k) = @out[k.to_s]
  def raw_set(key, value)
    @out[key.to_s] = value.to_s
    @out[key.to_s]
  end
  def out = @out
end

def fetch_any(n) = n > 0 ? { "devices" => [] } : Jar.new

j = Jar.new
j.raw_set(:a, "v")
p j.out
folder = fetch_any(1)
folder["devices"] << { "deviceID" => "A" }
folder["devices"].concat([{ "deviceID" => "B" }])
p folder

class Box
  def initialize = (@items = [+"x"])
  def [](i) = @items[i]
  def items = @items
end
b = Box.new
b[0] << "y"
p b.items
