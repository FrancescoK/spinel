# deprecate_constant in a class or module body declares, as private_constant
# does; the body raised NoMethodError. Rack's multipart parser has one.
# CRuby also warns on stderr where a deprecated constant is read; Spinel
# does not warn yet.

class P
  A = 1
  B = 2
  deprecate_constant :A, :B
  def self.x = A + B
end

module M
  C = "c"
  deprecate_constant :C
  if true
    D = "d"
    deprecate_constant :D
  end
end

p P.x, M::C, M::D
