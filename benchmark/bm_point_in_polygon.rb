# point_in_polygon - which polygons hold a point, over flat Float arrays
#
# Shapes kept the way a spatial index keeps them without an object per
# shape: each polygon's bounding box is four Floats of one array, its
# vertices x, y pairs of another. A query scans the boxes for the next one
# that holds the point, returning from the scan as soon as it finds one, and
# casts a ray over that polygon's edges. Measures loops whose work is
# comparing a value with array elements: the scan's box tests, and the ray
# cast's crossing tests and arithmetic.

class Polygons
  def initialize(count, sides, seed)
    @box = []
    @pts = []
    @first = []
    @n = count
    @sides = sides
    @r = seed
    count.times { add_polygon }
  end

  # A number below m, from the generator bm_huffman uses.
  def draw(m)
    @r = (@r * 1103515245 + 12345) % 2147483648
    @r % m
  end

  # A star-shaped polygon around a random center.
  def add_polygon
    cx = draw(100_000) / 100.0
    cy = draw(100_000) / 100.0
    radius = 2.0 + draw(2800) / 100.0
    @first << @pts.length
    min_x = cx
    min_y = cy
    max_x = cx
    max_y = cy
    k = 0
    while k < @sides
      d = radius * (0.5 + draw(1000) / 2000.0)
      a = 2.0 * Math::PI * k / @sides
      x = cx + d * Math.cos(a)
      y = cy + d * Math.sin(a)
      @pts << x << y
      min_x = x if x < min_x
      min_y = y if y < min_y
      max_x = x if x > max_x
      max_y = y if y > max_y
      k += 1
    end
    @box << min_x << min_y << max_x << max_y
  end

  # The first polygon from i on whose box holds (x, y), or -1.
  def next_box(x, y, i)
    while i < @n
      b = i * 4
      return i if x >= @box[b] && x <= @box[b + 2] && y >= @box[b + 1] && y <= @box[b + 3]
      i += 1
    end
    -1
  end

  # Whether polygon p holds (x, y): the even-odd ray cast over its edges.
  def inside?(p, x, y)
    first = @first[p]
    j = first + 2 * (@sides - 1)
    k = 0
    inside = false
    while k < @sides
      i = first + 2 * k
      yi = @pts[i + 1]
      yj = @pts[j + 1]
      if (yi > y) != (yj > y)
        xi = @pts[i]
        inside = !inside if x < (@pts[j] - xi) * (y - yi) / (yj - yi) + xi
      end
      j = i
      k += 1
    end
    inside
  end

  # How many polygons hold (x, y).
  def count_holding(x, y)
    hits = 0
    i = next_box(x, y, 0)
    while i >= 0
      hits += 1 if inside?(i, x, y)
      i = next_box(x, y, i + 1)
    end
    hits
  end
end

shapes = Polygons.new(3000, 24, 42)
held = 0
hits = 0
q = 0
while q < 4000
  h = shapes.count_holding(shapes.draw(100_000) / 100.0, shapes.draw(100_000) / 100.0)
  hits += h
  held += 1 if h > 0
  q += 1
end
p hits, held
