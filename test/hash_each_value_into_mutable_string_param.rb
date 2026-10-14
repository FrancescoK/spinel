# A Hash#each block's String value passed to a `[]=` whose stored values a
# caller appends to (through an index on a receiver of more than one class):
# the block parameter is a mutable String, and the Hash's plain String is
# bound to it as one.
class Flashy
  def initialize = (@h = {})
  def [](k) = @h[k]
  def []=(k, v)
    @h[k] = v
  end
  def h = @h
end

def fetch_any(n) = n > 0 ? { "devices" => [] } : Flashy.new

fl = Flashy.new
{ "notice" => "hi", "alert" => "no" }.each { |k, v| fl[k] = v }
p fl.h
folder = fetch_any(1)
folder["devices"] << { "deviceID" => "A" }
p folder
other = fetch_any(0)
other["x"] = +"ab"
other["x"] << "c"
p other.h
