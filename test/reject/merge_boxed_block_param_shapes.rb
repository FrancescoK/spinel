# A conflict block written at a merge! into a general Hash, its source boxed,
# has its pairs bound to its required parameters and a rest. Any other
# parameter would read nil, so a default, a keyword, a `**` and a parameter
# after a splat are each refused.
def opt(obj, s) = obj.merge!(s) { |k, a, b = 9| [k, a, b] }
p opt({ "a" => 1 }, { "a" => 2 })
p opt({ "c" => "x" }, { "c" => "y" })

def key(obj, s) = obj.merge!(s) { |k, a, b, x: 1| [k, a, b, x] }
p key({ "a" => 1 }, { "a" => 2 })
p key({ "c" => "x" }, { "c" => "y" })

def kwrest(obj, s) = obj.merge!(s) { |k, a, b, **o| [k, a, b, o] }
p kwrest({ "a" => 1 }, { "a" => 2 })
p kwrest({ "c" => "x" }, { "c" => "y" })

def post(obj, s) = obj.merge!(s) { |k, *m, l| [k, m, l] }
p post({ "a" => 1 }, { "a" => 2 })
p post({ "c" => "x" }, { "c" => "y" })
