# A String instance variable that no write has set yet is nil: count, sum,
# hex, lines, partition, rpartition, +@, encode, to_sym and intern on it raise
# nil's NoMethodError, as CRuby does. One set to nil raises the same way, and
# one set to a String answers for it.

class Route
  def initialize(stops, how)
    @stops = stops if how == :set
    @stops = nil if how == :cleared
  end
  def a_count = @stops.count("a")
  def vowel_count = @stops.count("aeiou", "^e")
  def checksum = @stops.sum
  def checksum8 = @stops.sum(8)
  def hex_value = @stops.hex
  def legs = @stops.lines
  def first_stop = @stops.partition(", ")
  def last_stop = @stops.rpartition(", ")
  def unfrozen = +@stops
  def encoded = @stops.encode
  def symbol = @stops.to_sym
  def interned = @stops.intern
end

def show(label)
  puts "#{label}: #{yield.inspect}"
rescue NoMethodError => e
  puts "#{label}: NoMethodError #{e.message}"
end

def report(name, r)
  show("#{name} count") { r.a_count }
  show("#{name} count(2)") { r.vowel_count }
  show("#{name} sum") { r.checksum }
  show("#{name} sum(8)") { r.checksum8 }
  show("#{name} hex") { r.hex_value }
  show("#{name} lines") { r.legs }
  show("#{name} partition") { r.first_stop }
  show("#{name} rpartition") { r.last_stop }
  show("#{name} +@") { r.unfrozen }
  show("#{name} encode") { r.encoded }
  show("#{name} to_sym") { r.symbol }
  show("#{name} intern") { r.interned }
end

report("line 7", Route.new("Children's Grand Park, Achasan\nGuui, Jayang-dong, Kondae\n", :set))
report("unset", Route.new("Seongsu", :unset))
report("cleared", Route.new("Han River", :cleared))
