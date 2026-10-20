# A module's self call whose name Kernel defines too (puts here) reaches
# the includers' methods when each of them defines it, as the share walk
# takes it (module_self_call_reaches_includers), and wherever the walk asks
# whether a call reaches a user method, it answers so for this call too.
# Taken there for Kernel#puts, which only prints, the Array handed in the
# module's own method, which those `puts` keep, would be a typed String
# container holding a shared String, and the program refused.
module Logbook
  def note(place)
    puts([place])
    place
  end
end

class Shelf
  include Logbook
  attr_reader :rows

  def initialize
    @rows = []
  end

  def puts(row) = @rows << row
end

class Wall
  include Logbook
  attr_reader :rows

  def initialize
    @rows = []
  end

  def puts(row) = @rows << row
end

shelf = Shelf.new
s = shelf.note(String.new("Jayang"))
s << "-dong"
p shelf.rows
wall = Wall.new
t = wall.note(String.new("Children's Grand Park"))
t << " Station"
p wall.rows
