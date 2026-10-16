# `self.tok ||= v` (and `&&=`) where the class defines neither tok nor
# tok= raises NoMethodError for the reader when it runs, as an ordinary
# call to an undefined method does. It was compiled as a write of an
# attribute's instance variable the class does not have, and its C did
# not compile.

class Guard
  def initialize = @n = 0
  def protect = self.token ||= :authenticity
  def keep = (self.token &&= :kept; :done)
  def value = (x = (self.token ||= 1); x)
  def n = @n
end

g = Guard.new
[:protect, :keep, :value].each do |m|
  begin
    p g.send(m)
  rescue NoMethodError => e
    puts "#{m}: #{e.message}"
  end
end
p g.n
