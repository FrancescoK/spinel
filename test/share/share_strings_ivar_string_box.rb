# Flag-only: boxing an ivar whose cached read type is String keeps its
# shared slot's handle, including the nullable object_id path.
class IvarBox
  def run
    @seed = +"ivar"
    values = Array.new(2, @seed)
    values[0] << "!"
    p @seed.equal?(values[1]), @seed.object_id == values[1].object_id
    @seed << "?"
    p values
  end
end
IvarBox.new.run
