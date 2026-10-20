# String#encoding and #ascii_only? on an instance variable that holds nil
# raise NoMethodError, as CRuby does: one no write has set yet, one a write
# set to nil, and one the program appends to in place. Each one set to a
# String answers for that String, binary or UTF-8.

class Stop
  def initialize(name, known) = (@name = name if known)
  def encoding = @name.encoding
  def encoding_name = @name.encoding.name
  def ascii_only? = @name.ascii_only?
end

class Platform
  def initialize(name, known) = (@name = known ? name : nil)
  def encoding = @name.encoding
  def ascii_only? = @name.ascii_only?
end

class Ferry
  def initialize(pier, known) = (@log = pier if known)
  def call_at(pier) = (@log << " > " << pier)
  def encoding = @log.encoding
  def ascii_only? = @log.ascii_only?
end

def show(label)
  puts "#{label}: #{yield.inspect}"
rescue NoMethodError => e
  puts "#{label}: NoMethodError #{e.message}"
end

seongsu = Stop.new("Seongsu", true)
jayang = Stop.new("자양동", true)
gmp = Stop.new("GMP".b, true)
achasan = Stop.new("Achasan", false)
show("Seongsu encoding") { seongsu.encoding }
show("Seongsu ascii_only?") { seongsu.ascii_only? }
show("자양동 encoding") { jayang.encoding }
show("자양동 ascii_only?") { jayang.ascii_only? }
show("GMP encoding") { gmp.encoding }
show("GMP encoding name") { gmp.encoding_name }
show("GMP ascii_only?") { gmp.ascii_only? }
show("Achasan encoding") { achasan.encoding }
show("Achasan encoding name") { achasan.encoding_name }
show("Achasan ascii_only?") { achasan.ascii_only? }

guui = Platform.new("Guui station", true)
kondae = Platform.new("Kondae", false)
show("Guui station encoding") { guui.encoding }
show("Kondae encoding") { kondae.encoding }
show("Kondae ascii_only?") { kondae.ascii_only? }

han = Ferry.new(+"Han River", true)
han.call_at("Jayang station")
icn = Ferry.new("ICN", false)
show("Han River encoding") { han.encoding }
show("Han River ascii_only?") { han.ascii_only? }
show("ICN encoding") { icn.encoding }
show("ICN ascii_only?") { icn.ascii_only? }

park = ["Kondae", "Achasan"].find { |s| s == "Children's Grand Park" }
show("Children's Grand Park encoding") { park.encoding }
show("Children's Grand Park ascii_only?") { park.ascii_only? }
