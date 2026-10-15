# A boxed receiver that holds a String or a module with its own `bytes` and
# `chars`, whose answers are Arrays of another kind: the call answers the
# boxed Array both arms fill. Since #9218 the dispatch builds the module's
# arm beside the String's, and with the call still typed as the String's
# Array the C did not compile; the String's own arm, re-entered inside the
# dispatch, also declined and raised NoMethodError.
module B
  def self.bytes = [1, "b"]
  def self.chars = [:c, 2]
end
g = { a: "hi", b: B }
p g[:a].bytes, g[:b].bytes
p g[:a].chars, g[:b].chars
p g[:a].bytes.size + g[:b].chars.size
