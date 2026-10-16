# A boxed String's `sub` beside a module's own `self.sub` that answers a
# Hash: the module's answer is narrowed off String (`value.is_a?(Hash) ?
# value : {}`), so it adds no String to the call's value, and the String's
# new `sub` is a String no other name holds. The module's answer was joined
# into the call's value, and with it every caller's local that kept a Hash
# from it: the variable's write was refused (campfire's
# ActiveStorage::Current.base_url beside its Params.sub). What the Hash
# holds is still shared: a change through one name shows through the other.
module Params
  def self.sub(params, key)
    value = params.fetch(key, {})
    if value.is_a?(Hash)
      value
    else
      {}
    end
  end
end
$params = { "user" => { "name" => +"ann" } }
$params["user"]["name"] << "!"
class Cur
  def self.base_url(options)
    return "" if options.nil?
    host = options.fetch(:host, "")
    return "" if host == ""
    protocol = options.fetch(:protocol, "http").sub("://", "")
    protocol << "s" if protocol == "http"
    protocol + "://" + host
  end
end
puts Cur.base_url({ host: "example.com", protocol: "https://" })
puts Cur.base_url({ host: "example.org" })
attrs = Params.sub($params, "user")
attrs["name"] << "?"
p $params, Params.sub($params, "none"), Params
