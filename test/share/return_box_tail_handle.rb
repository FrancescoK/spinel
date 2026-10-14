# A method whose value is a String (here pinned by an inline signature, as
# the flag's late widening leaves a Rails application's sanitize_tag_name
# and normalize_head_header_name in #8328) and whose tail the analysis
# boxed answers the String the box holds: the tail publishes the box's
# handle for the caller, or clears it for a box with none (a new String,
# nil), so a caller that keeps and changes the answer changes that String.
# A conditional's arms are not taken, and stay refused where they share.
class V
  #: (untyped) -> String
  def self.tag_name(raw)
    raw[0, 2].downcase
  end

  #: (untyped) -> String
  def self.pick(raw) = raw

  #: (untyped) -> String
  def self.ret(a)
    return a if a.is_a?(String) && a.size > 3
    a
  end
end

xs = [+"AbC", 1]
n = V.tag_name(xs[0])
m = n
m << "!"
p n

s = +"keep"
t = V.pick([s, 1][0])
t << "!"
r = V.ret([s, 2][0])
r << "?"
q = V.ret([+"ab", 3][0])
q << "#"
f = V.pick(["frozen", 4][0])
p s, t.equal?(s), q, f, f.frozen?, V.pick([nil, 5][0]).nil?

a = [+"x", 1]
h = { k: V.pick(a[0]) }
h[:k] << "y"
p a, [V.pick(a[0])].map { |z| z << "w" }, a
