# spinel: needs-rbs-parser
# spinel: not-cruby -- the annotations are false; Spinel checks an Array
# return whose body answers a boxed value when it returns, in every build,
# and a value that is no Array raises TypeError.
CONF = { "a" => [1, 2], "b" => "x", "n" => nil }

class Cfg
  #: (String) -> Array[Integer]
  def for(key) = CONF[key]
end

["a", "b", "n"].each do |k|
  p Cfg.new.for(k)
rescue TypeError => e
  p e.message
end
