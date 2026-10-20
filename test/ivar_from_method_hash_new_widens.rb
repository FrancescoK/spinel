# An ivar assigned the Hash a user method builds (`@params = R.str_hash`,
# whose `Hash.new("")` another caller keeps String-keyed) and then given
# a Symbol key and an Integer value: the ivar's slot widened to the
# poly-keyed variant, but the method still built the String-keyed one, so
# the store raised "the hash was not widened for this store". The method's
# `Hash.new` is now built as the slot's variant, as a hash literal it
# answered already was.
class IvhwRequest
  def self.str_hash
    Hash.new("")
  end

  def initialize
    @params = IvhwRequest.str_hash
  end

  def merge(src)
    src.each { |k, v| @params[k] = v }
    @params
  end
end

class IvhwForm
  define_singleton_method(:fields) { { "f" => +"2", g: 3 } }
end

headers = IvhwRequest.str_hash
headers["host"] = +"example.com"
p headers
p IvhwRequest.new.merge(IvhwForm.send(:fields))
p IvhwRequest.new.merge({ "x" => +"y" })
