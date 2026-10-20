# Inline annotations and the same signatures through --rbs give the same C
# for a Hash return whose body answers a boxed value: the box is kept, and
# checked to be a Hash when the method returns (test/rbs_hash_return_box.rb
# is the case the check lets compile at all).

BOXED_KEYS = {}
BOXED_KEYS[["x", 1].first] = "boxed"

CONF = {
  "a" => { "x" => "1", "y" => "2" },
  "b" => 2,
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
holder = [cfg, nil].first
p(styles.map { |st| holder.for("a")[st]&.include?("2") })
p cfg.maybe("k")
p cfg.maybe("a")["x"]
p cfg.early("boxed")["x"]
p cfg.early("boxed").equal?(BOXED_KEYS)
p cfg.early("a")["y"]
