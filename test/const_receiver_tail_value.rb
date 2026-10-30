module Target
  class C
    def self.v = 3
  end
end
def run = yield + 1
module M
  def self.go = run { M::H::C.v }
end
begin
  p M.go
rescue NameError => e
  puts e.message
end
M::H = Target
p M.go
