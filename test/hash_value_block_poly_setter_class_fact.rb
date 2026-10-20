# A Hash value block that stores its value through a poly receiver
# (`req.params[k] = v`, an ivar holding String-keyed Hashes of two kinds)
# was taken to hand the value to every program class's `[]=`, Node's among
# them, which appends to its value: the Strings the iterated Hash holds were
# refused ("a String stored in a Hash is passed to an appending value
# block"). The receiver's class fact names Hash alone, so Node's `[]=` is
# no candidate. Roundhouse's Tep::Request stopped there (`req.req_params`).
class HvbpNode
  def []=(key, value)
    value << "!" if value.is_a?(String)
  end
end

class HvbpRequest
  attr_accessor :params

  def self.str_hash
    Hash.new("")
  end

  def initialize
    @params = HvbpRequest.str_hash
  end
end

class HvbpForm
  define_singleton_method(:fields) { { "f" => +"2", (rand > 2 ? :g : "g") => (rand > 2 ? 3 : +"3") } }
end

headers = HvbpRequest.str_hash
headers["host"] = +"example.com"
p headers

node = HvbpNode.new
node["a"] = +"x"
node["b"] = 1

req = HvbpRequest.new
HvbpForm.send(:fields).each do |k, v|
  req.params[k] = v
end
p req.params
