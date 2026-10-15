# A boxed receiver's `sub` beside a module's own `self.sub` whose answer is a
# Hash: the String's `sub` is taken by the String shortcut, which builds no
# class arm, so the call stays a String. Widened to a box when the class
# method's answer disagreed (#9192), the call's slot was a box the shortcut
# wrote a `const char *` into, and the C did not compile (campfire's
# ActiveStorage::Current.base_url beside its Params.sub).
module Params
  def self.sub(params, key)
    v = params[key]
    v.is_a?(Hash) ? v : {}
  end
end
class Cur
  def self.base_url(options)
    return "" if options.nil?
    host = options.fetch(:host, "")
    return "" if host == ""
    protocol = options.fetch(:protocol, "http").sub("://", "")
    protocol + "://" + host
  end
end
puts Cur.base_url({ host: "example.com", protocol: "https://", port: 1 })
puts Cur.base_url({ host: "example.org" })
p Params.sub({ "a" => { "b" => 1 } }, "a")
p Params
