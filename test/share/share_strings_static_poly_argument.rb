# Flag-only: a boxed receiver's argument holds the shared static slot,
# so either direction of an identity query observes the same String.
$poly_seed = +"seed"
a = [$poly_seed]
$poly_seed << "!"
p a[0].equal?($poly_seed), $poly_seed.equal?(a[0])
p a[0].object_id == $poly_seed.object_id
# The held argument remains the old object if a later argument rebinds it.
class Holder
  attr_reader :value
  def take(value, ignored) = (@value = value)
end
class OtherHolder
  attr_reader :value
  def take(value, ignored) = (@value = value)
end
[Holder.new, OtherHolder.new].each do |holder|
  old = $poly_seed
  holder.take($poly_seed, ($poly_seed = +"next"))
  old << "?"
  p holder.value.equal?(old), holder.value.object_id == old.object_id
  p holder.value, $poly_seed
end
