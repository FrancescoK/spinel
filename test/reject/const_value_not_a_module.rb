# The module half of the same thing: CRuby says "B is not a module" and does
# not load the file (#4318).
# spinel: reject-constant-kind
B = 1

module B
  def self.hi = "hi"
end

p B.hi
