# Hash.new(*args) and Array.new(*args) with a length known only at run time
# branch on the length, even where another class defines its own
# `self.new(*args)` or `self.new(**kw)`: that method never answers a call
# on Hash or Array.
class Other
  def self.new(*args)
    [:other, args]
  end
end
class Kw
  def self.new(**kw) = [:kw, kw]
end
p Other.new(1, 2)
p Kw.new(a: 1)
def make(*args) = Hash.new(*args)
p make[:x]
p make(5)[:x]
begin
  make(5, 6)
rescue ArgumentError => e
  p e.message
end
def fill(*args) = Array.new(*args)
p fill
p fill(2)
p fill(2, :z)
begin
  fill(1, 2, 3)
rescue ArgumentError => e
  p e.message
end
