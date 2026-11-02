module M
  p((b rescue :nameerr))
  def self.b = 2
  p b
end
