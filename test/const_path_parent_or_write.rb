class Tgt; end
def pr(x) = (puts x; x)
module M
  def self.go
    M::LP::Y ||= pr(3)
    p M::LP::Y
  rescue NameError
    puts 'NameError'
  end
end
M.go
M::LP = Tgt
M.go
