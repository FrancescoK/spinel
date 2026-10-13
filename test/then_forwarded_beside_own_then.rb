# A program class's own `then` or `tap` does not stop a forwarded callable
# from reaching Kernel#then / #tap on a receiver of another class; a
# receiver of that class still calls its own.
class ThenOwner
  def then(&b) = "own then"
  def tap = "own tap"
end
up = :upcase.to_proc
p "c".then(&:upcase), "d".then(&up), [1, 2].tap(&:pop), 4.then(&:succ)
p ThenOwner.new.then(&up), ThenOwner.new.tap
