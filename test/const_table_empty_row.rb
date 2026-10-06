# A constant or an instance variable holding a table of Integer rows hands
# out each row as an Integer Array. An empty row is built as a general
# Array, so a read of it took its length for 8 and its storage for eight
# zeros, and an append to the row read out was lost.
GRAPH = [[1, 2], [], [3], []]
p GRAPH[1]
p GRAPH[1].size
p GRAPH[3].empty?
p GRAPH[1].first
p GRAPH[1] == []
p GRAPH[1].map { |v| v * 2 }
i = 0
while i < GRAPH.size
  p GRAPH[i].size
  i += 1
end
row = GRAPH[1]
row << 5
p row, GRAPH
def neighbours(n) = GRAPH[n]
p neighbours(3)
neighbours(3) << 0
p GRAPH
GRAPH.each { |a, b| p [a, b] }
GRAPH.reverse_each { |a, b| p [a, b] }

FROZEN = [[1, 2], [], [3, 4]].freeze
p FROZEN[1], FROZEN[1].size, FROZEN[0].size
FROZEN.each { |a, b| p [a, b] }

module Maze
  STEPS = [[0, 1], [], [1, 0]]
  def self.width(n) = STEPS[n].size
end
p Maze.width(1), Maze.width(2), Maze::STEPS[1]

# a row stored later
LATER = [[1, 2], [3, 4]]
LATER[1] = []
p LATER[1], LATER[1].size

# a bare Array.new and an empty Hash are rows of the same kind
MIXED = [[1, 2], Array.new, {}]
p MIXED[1].size, MIXED[2].size

class Table
  def initialize
    @rows = [[1, 2], [], [3, 4]]
  end
  def show
    @rows.each { |a, b| p [a, b] }
    p @rows[1], @rows[1].size
    @rows[1] << 7
    p @rows
  end
end
Table.new.show

# a row pushed later
class Grown
  def initialize
    @rows = [[1, 2], [3, 4]]
  end
  def grow
    @rows << []
    @rows.insert(0, Array.new)
    p @rows.inspect
    p @rows[0].size, @rows[3].size, @rows[3]
  end
end
Grown.new.grow

# a table with no empty row answers as before
PLAIN = [[1, 2], [3, 4]]
p PLAIN[1], PLAIN[1].size, PLAIN[1][0] + PLAIN[0][1]
PLAIN.each { |a, b| p a + b }
