# A String the program shares, answered by a method and handed to a
# parameter that only reads it for the length of the call (one the walk
# lends the argument), goes as that lend goes: the argument's own flow,
# whose destination shares nothing, is not refused beside it (#9258
# cluster 14). A callee that changes its parameter is no lend.
def pick(h, k, fb)
  v = h.fetch(k, fb)
  v.is_a?(String) ? v.to_s : fb
end
def sig(id) = "blob:" + id
signed = +"abc"
signed << "def"
h = { "a" => signed, "n" => 1 }
p sig(pick(h, "a", ""))
