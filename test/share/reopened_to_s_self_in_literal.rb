# A String reopening's `def to_s = self` answers its receiver untouched, so
# `[s.to_s]` holds s's own String, as the builtin conversion does: a
# change made through another name is seen there, and equal? is true.
class String
  def to_s = self
end
class Domain
  def initialize(name) = @name = name
  def qualify = (@name << ".com"; nil)
end
def target_names(target)
  target.is_a?(Array) ? target.map { |c| c.to_s } : [target.to_s]
end
name = +"example"
Domain.new(name).qualify
target = [name][0]
p target_names(target)
p target_names(target)[0].equal?(target)
