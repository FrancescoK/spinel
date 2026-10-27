# `T[key] = v` with a String key the loop computes stores a frozen copy of
# it when T is a Hash, and the key itself when T is another object, which
# the loop's analysis does not know: the loop stays as written and runs
# when the program does.
module K
  NAMES = { "a" => "x", "b" => "y" }
  T = {}
  NAMES.each { |k, v| T["#{k}!"] = v }
end
p K::T, K::T.keys.map(&:frozen?)
