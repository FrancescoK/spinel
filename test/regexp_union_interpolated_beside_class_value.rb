# Regexp.union of operands one of which is interpolated, in a program that
# also takes Regexp as a value: the class-method arms took the call ahead
# of Regexp's own and refused it ("no class in the program defines a class
# method 'union'"). Rack::Request builds its trusted-proxy pattern this
# way, and ActionDispatch::Http::URL its VALID_IP_HOSTNAME.
klass = Regexp
p klass

valid_ipv4_octet = /\.(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])/
trusted = Regexp.union(
  /\A127#{valid_ipv4_octet}{3}\z/,
  /\A::1\z/,
  /\Alocalhost\z|\Aunix(\z|:)/i,
)
p trusted.match?("127.0.0.1"), trusted.match?("LOCALHOST"), trusted.match?("8.8.8.8")
p Regexp.union("a.", /b#{1}/), Regexp.escape("x.y"), /q/.is_a?(Regexp)

class Regexp
  def self.custom = :own
end
p Regexp.custom
