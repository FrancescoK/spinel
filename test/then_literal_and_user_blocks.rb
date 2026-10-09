# spinel: share
# Literal builtin blocks and user-owned methods keep their supported paths.
p "a".then { |s| s.upcase }
p "b".yield_self { |s| s + "!" }
p "c".then(&:upcase)
p "d".then.to_a
class ThenOwner
  def then(&block)
    block.call("own")
  end
end
convert = ->(value) { value + "!" }
p ThenOwner.new.then(&convert)
