# A String instance variable the program appends to in place is nil until a
# write sets it: a call that only reads its bytes raises nil's NoMethodError,
# as CRuby does, and to_i and to_f answer as nil's do. Set, each answers for
# the String it holds.

class Ferry
  def initialize(pier, known) = (@log = pier if known)
  def call_at(pier) = (@log << " > " << pier)
  def length = @log.length
  def size = @log.size
  def bytesize = @log.bytesize
  def empty? = @log.empty?
  def upcase = @log.upcase
  def chars = @log.chars.first(3)
  def first = @log[0]
  def stops_at?(pier) = @log.include?(pier)
  def starts_at?(pier) = @log.start_with?(pier)
  def position(pier) = @log.index(pier)
  def legs = @log.split(" > ")
  def number = @log.to_i
  def fare = @log.to_f
end

def show(label)
  puts "#{label}: #{yield.inspect}"
rescue NoMethodError => e
  puts "#{label}: NoMethodError #{e.message}"
end

han = Ferry.new(+"Han River", true)
han.call_at("Jayang station")
han.call_at("Seongsu")
icn = Ferry.new("ICN", false)
[["Han River", han], ["ICN", icn]].each do |name, ferry|
  show("#{name} length") { ferry.length }
  show("#{name} size") { ferry.size }
  show("#{name} bytesize") { ferry.bytesize }
  show("#{name} empty?") { ferry.empty? }
  show("#{name} upcase") { ferry.upcase }
  show("#{name} chars") { ferry.chars }
  show("#{name} [0]") { ferry.first }
  show("#{name} include?") { ferry.stops_at?("Seongsu") }
  show("#{name} start_with?") { ferry.starts_at?("Han") }
  show("#{name} index") { ferry.position("Jayang") }
  show("#{name} split") { ferry.legs }
  show("#{name} to_i") { ferry.number }
  show("#{name} to_f") { ferry.fare }
end
