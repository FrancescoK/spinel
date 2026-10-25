# A Hash#update of the program's own, bound with alias, is kept for a
# Hash literal receiver.
class Hash
  def quiet_update(o) = (puts "aliased update"; self)
  alias update quiet_update
end

p({ "q" => 1 }.update({ "a" => 2 }))
