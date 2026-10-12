# A program that gives a class a class_eval of its own runs the block as
# that method says, here with the caller's self.
class Own
  def self.class_eval = yield
  def self.z = @z
end
@z = :top
Own.class_eval { @z = 3 }
p [Own.z, @z]
