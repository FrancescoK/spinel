# Array#index with a block and no argument is find_index, also through a
# delegator and on a value that is either a program's class defining index
# (tty-prompt's Choices) or an Array (a filtered list): each answers its own.
class Choices
  include Enumerable
  def initialize(a) = @choices = a
  def index(*args, &block)
    @choices.index(*args, &block)
  end
  def each(&block)
    return to_enum unless block

    @choices.each(&block)
  end
end
def pick(f) = f ? Choices.new([5, 6, 7]) : [7, 8]
[true, false].each do |f|
  c = pick(f)
  p c.index { |x| x > 5 }
  p c.index(7)
end
