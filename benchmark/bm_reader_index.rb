# reader_index - indexing through another object's readers in a hot loop
#
# `m.data[i * m.cols + j]` is how object-oriented code reads a matrix, a
# grid or a buffer it does not own: the loop only reads, through two
# attr_readers and a typed array. Measures that the reads compile to plain
# field and element loads, with no temps held between them.

class Matrix
  attr_reader :data, :rows, :cols

  def initialize(rows, cols)
    @rows = rows
    @cols = cols
    @data = Array.new(rows * cols) { |k| (k % 17) * 0.25 }
  end
end

class Grid
  attr_reader :cells, :width

  def initialize(width, height)
    @width = width
    @cells = Array.new(width * height) { |k| k % 7 }
  end
end

def matrix_sum(m, reps)
  s = 0.0
  r = 0
  while r < reps
    i = 0
    while i < m.rows
      j = 0
      while j < m.cols
        s += m.data[i * m.cols + j]
        j += 1
      end
      i += 1
    end
    r += 1
  end
  s
end

def grid_neighbours(g, height, reps)
  n = 0
  r = 0
  while r < reps
    y = 1
    while y < height - 1
      x = 1
      while x < g.width - 1
        n += g.cells[(y - 1) * g.width + x] + g.cells[(y + 1) * g.width + x] +
             g.cells[y * g.width + x - 1] + g.cells[y * g.width + x + 1]
        x += 1
      end
      y += 1
    end
    r += 1
  end
  n
end

p matrix_sum(Matrix.new(500, 400), 500)
p grid_neighbours(Grid.new(400, 300), 300, 200)
