# spinel: gc-minor
# An explicit reflective write on Object's boxed self reaches a class's slot.
class Object
  def reflective_store(v) = instance_variable_set(:@value, v)
  def source_store(v) = (@count = v)
end
class ClassStore
  @value = :old
  def self.value = @value
  @count = 1
  def self.count = @count
end
ClassStore.reflective_store(:new)
p ClassStore.value
ClassStore.source_store(41)
p ClassStore.count
ClassStore.source_store(2.5)
p ClassStore.count
