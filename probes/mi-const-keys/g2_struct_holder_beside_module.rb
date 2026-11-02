Pair = Struct.new(:left)
Pair::SIZE = 1.5
module Grid
  SIZE = 10
  def self.cells = SIZE * 2
end
p Pair::SIZE, Grid::SIZE, Grid.cells
