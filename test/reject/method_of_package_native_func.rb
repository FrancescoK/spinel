# A Method object of a package's native_func has no compiled function to
# bind, as a builtin module's has none. Its module is a user module, so it
# took the user method path and bound the Method to Object: the call answered
# nil, or raised NoMethodError for strict_decode64 on an Object (#7554). It is
# refused at the call, naming it.
require "base64"
h = { "a" => "aGk=" }
p h.transform_values(&Base64.method(:strict_decode64))
