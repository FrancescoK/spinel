# A table of empty rows takes its row kind from the pushes into its rows
# `Array.new(n) { [] }` builds rows with no kind of their own.
# When every row the table hands out is pushed only Integers (or only Floats)
# and goes nowhere else, the table is a table of Integer (Float) Arrays, as an
# `Array[Array[Integer]]` annotation already made it. Any other use of a row
# (held in a local, passed to a method, walked by the table's each, pushed
# another kind) keeps the table boxed, and every answer is CRuby's either way.

# an adjacency list filled through a method and walked from outside the class
class Graph
  attr_reader :adj

  def initialize(n)
    @adj = Array.new(n) { [] }
  end

  def add_edge(u, v)
    @adj[u] << v
    @adj[v] << u
  end
end

g = Graph.new(6)
[[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [0, 5], [1, 4]].each { |u, v| g.add_edge(u, v) if u != v }

def bfs(g, start, target)
  seen = Array.new(g.adj.size, false)
  queue = [[start, 0]]
  seen[start] = true
  until queue.empty?
    v, d = queue.shift
    g.adj[v].each do |w|
      return d + 1 if w == target
      next if seen[w]
      seen[w] = true
      queue << [w, d + 1]
    end
  end
  -1
end
p bfs(g, 0, 3), bfs(g, 2, 5), g.adj[1].size, g.adj[4].sum, g.adj[0].first, g.adj[5].last

# a local table, its rows read by index, first, last, include?, min and max
t = Array.new(3) { [] }
t[0].push(4, 2)
t.first << 9
t[2] << 1
p t[0][1], t.last.size, t[0].include?(9), t[0].min, t[0].max, t[1].empty?

# Float rows; and a literal of empty rows, whose rows are taken boxed before
# their kind is known, so its table stays boxed
f = Array.new(2) { [] }
f[0] << 1.5
f[1] << 0.25
p f[0][0] * 2, f[1].sum
l = [[], []]
l[0] << 5
l[1] << 6
p l[0][0] + l[1][0]

# rows that must stay boxed: each line's table is CRuby's
a = Array.new(3) { [] }
a[0] << 1
a[1] << "x"
p a
b = Array.new(3) { [] }
b[0] << 1
r = b[1]
r << 2.5
p b
c = Array.new(2) { [] }
c[0] << 1
c[1] << 1.5
p c
d = Array.new(3) { [] }
d[0] << 1
d.each { |row| row << nil }
p d
def push_z(row) = row << "z"
e = Array.new(2) { [] }
e[1] << 4
push_z(e[0])
p e
h = Array.new(2) { [] }
x = (h[0] << 1)
x << "y"
p h
k = Array.new(2) { [] }
k[0] << 1 << 2
p k
m = Array.new(2) { [] }
m[0] << 1
m[1] = ["s"]
p m
def fill(tab) = tab[0] << "w"
n = Array.new(2) { [] }
n[1] << 3
fill(n)
p n

class Rows
  attr_reader :rows

  def initialize = @rows = Array.new(2) { [] }

  def add(i, v) = @rows[i] << v
end
rs = Rows.new
held = rs.add(0, 1)
held << "z"
p rs.rows

# a program's own each reads what its block answers: the row add hands back
class Yielder
  def each
    x = yield
    x << "s"
  end
end

class Cells
  attr_reader :cells

  def initialize = @cells = Array.new(2) { [] }

  def add(v)
    @cells[0] << v
  end
end
cs = Cells.new
cs.add(1)
Yielder.new.each do
  cs.add(2) if cs.cells[1].empty?
end
p cs.cells
