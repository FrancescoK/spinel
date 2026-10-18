# spinel: not-cruby -- the annotations are false; Spinel checks a Hash
# return whose body answers a boxed value when it returns, in every build,
# and raises TypeError where the value is no Hash (or nil without `?`).
# CRuby does not read the annotations.

CONF = { "a" => { "x" => "1" }, "b" => 2, "c" => [1], "n" => nil }.freeze

class Cfg
  #: (String) -> Hash[String, String]
  def for(key) = CONF[key]
end

cfg = Cfg.new
p cfg.for("a")["x"]
%w[b c n].each do |k|
  begin
    cfg.for(k)
  rescue TypeError => e
    puts e.message
  end
end
