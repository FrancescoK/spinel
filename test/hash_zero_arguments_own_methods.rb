# A program's own Hash#update and Hash#merge! are what a call with no argument
# reaches, on a Hash of any key kind.
class Hash
  def update(*args) = 42
  def merge!(*args) = 43
end

p({ a: 1 }.update)
p({ "k" => 1 }.merge!)
h = { 1 => 2 }
p h.update
p h.merge!
m = { a: 1, "b" => 2.5 }
p m.update
p m.merge!
p h.update { |k, a, b| a }
