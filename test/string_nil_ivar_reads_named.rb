# A String instance variable that no write has set yet is nil: slice and
# [], match?, between?, unpack1 and the each_char, each_byte and each_line
# Enumerators on it raise nil's NoMethodError under the name the call is
# written with, as CRuby does. One set to nil raises the same way, and one
# set to a String answers for it.

TERMINUS = /station\z/

class Station
  def initialize(name, how)
    @name = name if how == :set
    @name = nil if how == :cleared
  end
  def first = @name.slice(0)
  def head = @name.slice(0, 4)
  def head_range = @name.slice(0..3)
  def part = @name.slice("Kon")
  def at0 = @name[0]
  def part_at = @name["Kon"]
  def pattern_at = @name[/K./]
  def kondae? = @name.match?(/dae/)
  def kondae_from?(i) = @name.match?(/dae/, i)
  def named?(s) = @name.match?(s)
  def terminus?(re) = @name.match?(re)
  def terminus_from?(re, i) = @name.match?(re, i)
  def central? = @name.between?("Achasan", "Seongsu")
  def tag = @name.unpack1("a3")
  def byte1 = @name.unpack1("C", offset: 1)
  def letters = @name.each_char.first(3)
  def codes = @name.each_byte.first(2)
  def lines = @name.each_line.to_a
  def words = @name.each_line(" ").to_a
end

def show(label)
  puts "#{label}: #{yield.inspect}"
rescue NoMethodError => e
  puts "#{label}: NoMethodError #{e.message}"
end

def report(label, s)
  show("#{label} slice(0)") { s.first }
  show("#{label} slice(0, 4)") { s.head }
  show("#{label} slice(0..3)") { s.head_range }
  show("#{label} slice(\"Kon\")") { s.part }
  show("#{label} [0]") { s.at0 }
  show("#{label} [\"Kon\"]") { s.part_at }
  show("#{label} [/K./]") { s.pattern_at }
  show("#{label} match?") { s.kondae? }
  show("#{label} match?(re, 2)") { s.kondae_from?(2) }
  show("#{label} match?(str)") { s.named?("Kon") }
  show("#{label} match?(Regexp value)") { s.terminus?(TERMINUS) }
  show("#{label} match?(Regexp value, 2)") { s.terminus_from?(TERMINUS, 2) }
  show("#{label} between?") { s.central? }
  show("#{label} unpack1") { s.tag }
  show("#{label} unpack1(offset:)") { s.byte1 }
  show("#{label} each_char") { s.letters }
  show("#{label} each_byte") { s.codes }
  show("#{label} each_line") { s.lines }
  show("#{label} each_line(sep)") { s.words }
end

report("Kondae", Station.new("Kondae station", :set))
report("unset", Station.new("Jayang station", :unset))
report("cleared", Station.new("Guui station", :cleared))
