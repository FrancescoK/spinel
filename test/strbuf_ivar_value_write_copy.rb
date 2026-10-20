# A new String written to an instance variable the program appends to in
# place (`@log << " > " << pier`, which holds the variable's String as a
# shared handle), where the write is a value too: an endless method's
# `(@log = pier.dup)`. The statement form wraps the new String in a handle
# of its own; the value form stored its bytes in the handle's slot, and the
# C did not compile. The write's value is the String the variable holds,
# which a later append changes too.

class Ferry
  def initialize(pier) = (@log = pier.dup)
  def reset(pier) = (@log = +pier)
  def board(pier) = (@log = pier.clone(freeze: false))
  def shout(pier) = (@log = pier.upcase)
  def call_at(pier) = (@log << " > " << pier)
  def log = @log
end

ferry = Ferry.new("Han River")
ferry.call_at("Jamsil")
puts ferry.log
first = ferry.reset("Ttukseom")
ferry.call_at("Seongsu")
puts first
puts ferry.board("Jayang").frozen?
ferry.call_at("Guui")
puts ferry.log
loud = ferry.shout("Kondae")
ferry.call_at("Achasan")
puts loud

class Shuttle
  def initialize(stop) = (@route = stop + "")
  def via(a, b) = @route.concat(" > ", a, " > ", b)
  def route = @route
end

shuttle = Shuttle.new("ICN")
shuttle.via("Seongsu", "GMP")
puts shuttle.route

class Line
  def self.start(stop) = (@stops = stop[0..])
  def self.add(stop) = (@stops << ", " << stop)
  def self.stops = @stops
end

Line.start("Children's Grand Park")
Line.add("Achasan")
puts Line.stops
