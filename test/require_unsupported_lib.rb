# A `require` of a natively-provided lib (json) is a no-op and the module still
# works (under SPINEL_STRICT_REQUIRE the require also records the feature, enabling
# JSON). An unsupported stdlib like tmpdir would instead be a compile-time
# "cannot load such file" under the gate, so it is not exercised here.
require "json"
puts JSON.generate([1, 2, 3])
puts "ok"
