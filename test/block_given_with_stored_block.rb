# A method that asks block_given? and also keeps its &blk as a value (in a
# list) is a real function taking the proc; block_given? answers whether it
# is there.
class Job
  def initialize = @list = []
  def item(label = "", &blk)
    raise ArgumentError, "no block" unless block_given?
    @list << [label, blk]
    self
  end
  def has?(&blk) = block_given?
  attr_reader :list
end
j = Job.new
j.item("a") { 1 }.item("b") { 2 }
p j.list.map { |l, b| [l, b.call] }
p j.has? { }, j.has?
begin
  j.item("c")
rescue ArgumentError => e
  p e.message
end
