# spinel: gc-stress
# pop, shift, delete_at and clear on an @ivar that holds objects of one
# class keep it an unboxed object array, and answer as CRuby does: the
# element taken out, nil for an empty array or an index outside it, and
# the array itself for clear. A method called on that nil raises
# NoMethodError. An Array of Integer Arrays takes the same calls, and stays
# boxed.
class Job
  attr_reader :name
  def initialize(name) = @name = name
end

class Backlog
  def initialize = @jobs = []
  def add(name) = @jobs << Job.new(name)
  def size = @jobs.size
  def names = @jobs.map(&:name).join(",")
  def take_last = @jobs.pop
  def take_first = @jobs.shift
  def take_at(i) = @jobs.delete_at(i)
  def drop_all
    @jobs.clear
    nil
  end
  def reset = @jobs.clear
end

q = Backlog.new
%w[a b c d e f].each { |n| q.add(n) }
puts q.take_last.name
puts q.take_first.name
puts q.take_at(1).name
puts q.take_at(-1).name
p q.take_at(5)
p q.take_at(-5)
puts q.names
# a new object between the removals, so a collection runs with the moved
# elements in place
q.add("g")
puts q.take_first.name
puts q.names
q.drop_all
puts q.size
p q.take_last
p q.take_first
p q.take_at(0)
q.add("h")
q.reset
puts q.size
q.add("i")
puts q.names
q.drop_all
begin
  puts q.take_last.name
rescue NoMethodError => e
  puts e.message
end
begin
  puts q.take_at(3).name
rescue NoMethodError => e
  puts e.message
end

rows = [[1, 2], [3, 4], [5, 6]]
p rows.pop
p rows.shift
p rows.delete_at(0)
rows << [7, 8]
rows.clear
p rows
