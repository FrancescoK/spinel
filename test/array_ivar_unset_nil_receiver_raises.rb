# An Array instance variable that no initialize sets first is nil until a
# method sets it, and a call on it raises nil's NoMethodError once its
# arguments have run, whatever the elements. Read as an empty Array, `[]`
# answered nil, `each` ran no block and `join` answered "", and `first(2)`,
# `take` and `sum` read through the NULL receiver.

$log = []
def note(v) = ($log << v; v)

def show(label)
  r = begin
    yield.inspect
  rescue NoMethodError => e
    "#{e.class} #{e.message}"
  end
  puts "#{label}: #{$log.join(" ")} -> #{r}"
  $log.clear
end

class Line
  def initialize(known)
    return unless known
    @stops = ["Jayang", "Guui", "Kondae"]
    @fares = [1400, 1500, 1650]
    @hops = [1.5, 2.25]
    @legs = [[1, 2], [3]]
  end
  def at(i) = @stops[note(i)]
  def range(i, n) = @stops[note(i), note(n)]
  def first(n) = @stops.first(note(n))
  def last(n) = @stops.last(note(n))
  def take(n) = @stops.take(note(n))
  def drop(n) = @stops.drop(note(n))
  def fetch(i) = @stops.fetch(note(i))
  def dig(i) = @stops.dig(note(i))
  def values_at(i) = @stops.values_at(note(i))
  def index(s) = @stops.index(note(s))
  def join(s) = @stops.join(note(s))
  def reverse = @stops.reverse
  def rotate(n) = @stops.rotate(note(n))
  def each = (@stops.each { |s| $log << s }; :done)
  def map = @stops.map(&:upcase)
  def push(s) = @stops.push(note(s))
  def fare(i) = @fares[note(i)]
  def fares(n) = @fares.first(note(n))
  def sum = @fares.sum
  def hop(i) = @hops[note(i)]
  def hops(n) = @hops.take(note(n))
  def leg(i) = @legs[note(i)]
  def legs(n) = @legs.first(note(n))
end

[true, false].each do |known|
  line = Line.new(known)
  k = known ? "Line" : "nil"
  show("#{k} [1]") { line.at(1) }
  show("#{k} [1, 2]") { line.range(1, 2) }
  show("#{k} first(2)") { line.first(2) }
  show("#{k} last(2)") { line.last(2) }
  show("#{k} take(2)") { line.take(2) }
  show("#{k} drop(1)") { line.drop(1) }
  show("#{k} fetch(1)") { line.fetch(1) }
  show("#{k} dig(0)") { line.dig(0) }
  show("#{k} values_at(2)") { line.values_at(2) }
  show("#{k} index") { line.index("Guui") }
  show("#{k} join") { line.join("-") }
  show("#{k} reverse") { line.reverse }
  show("#{k} rotate(1)") { line.rotate(1) }
  show("#{k} each") { line.each }
  show("#{k} map") { line.map }
  show("#{k} push") { line.push("Achasan") }
  show("#{k} fares[1]") { line.fare(1) }
  show("#{k} fares.first(2)") { line.fares(2) }
  show("#{k} fares.sum") { line.sum }
  show("#{k} hops[0]") { line.hop(0) }
  show("#{k} hops.take(1)") { line.hops(1) }
  show("#{k} legs[1]") { line.leg(1) }
  show("#{k} legs.first(1)") { line.legs(1) }
end
