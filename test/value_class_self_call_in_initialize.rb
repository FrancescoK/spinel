# A class Spinel passes by value (its instances are small and nothing reads
# their ivars back) takes self by value in its methods, but its initialize
# builds the object through a pointer: a call of another of its methods on
# self there passed the pointer, and the C did not compile.

class Pane
  def initialize
    @pid = run
  end

  def run = 1
end

Pane.new

class Tile
  def initialize(n)
    @a = self.size(n)
    @b = (x = size(n + 1); x)
  end

  def size(n) = n * 2
end

Tile.new(3)
p :ok
