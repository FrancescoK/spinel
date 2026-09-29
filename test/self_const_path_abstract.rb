# `self::KEYBYTES` in a class method that only subclasses define: each
# subclass answers its own, and the base class raises NameError, as in CRuby
# (rbnacl's Auth.key_bytes). The base's raising reader had no value for the
# poly slot and the C did not build.
class Auth
  def self.key_bytes = self::KEYBYTES
end
class HmacA < Auth
  KEYBYTES = [1, "a"].sample(1).first
end
class HmacB < Auth
  KEYBYTES = 64
end
p HmacB.key_bytes
x = HmacA.key_bytes
p x == 1 || x == "a"
begin
  Auth.key_bytes
rescue NameError => e
  p e.class
end
