# A method an RBS signature declares to return a Hash, whose body answers a
# value only the run time types (a read out of a Hash of mixed values, one
# of them a lambda that appends to its argument). The value stays boxed, a
# Hash of whatever form it is, and is checked to be a Hash when it returns;
# a String handed to `[]` on the result is then no String a proc could
# append to, which the compiler refused before.

BOXED_KEYS = {}
BOXED_KEYS[["x", 1].first] = "boxed"

CONF = {
  "a" => { "x" => "1", "y" => "2" },
  "b" => 2,
  "c" => ->(t) { t << "?" },
  "k" => nil
}.freeze

class Cfg
  #: (String) -> Hash[String, String]
  def for(key) = CONF[key]

  #: (String) -> Hash[String, String]?
  def maybe(key) = CONF[key]

  #: (String) -> Hash[String, String]
  def early(key)
    return BOXED_KEYS if key == "boxed"

    CONF[key]
  end
end

cfg = Cfg.new
styles = %w[x y z]
p(styles.map { |st| cfg.for("a")[st]&.include?("1") })
p cfg.for("a").key?("y")
p cfg.maybe("k")
p cfg.maybe("a")["x"]
p cfg.early("boxed")["x"]
p cfg.early("boxed").equal?(BOXED_KEYS)
p cfg.early("a")["y"]
p CONF["c"].call(+"z")
