# spinel: gc-stress
class Batch
  def initialize(items) = @items = items
  def map(&block) = @items.map(&block)
end

class Ender
  attr_reader :ended

  def initialize(seed) = @ended = seed

  def run(source)
    @ended = []
    @ended.concat(source.map { |item| item * 2 })
    @ended << source.map { |item| item + 1 }
  end
end

def source(i) = i == 0 ? Batch.new([1, 2]) : [3]

e = Ender.new(+"x")
e.run(source(0))
p e.ended
e.run(source(1))
p e.ended
