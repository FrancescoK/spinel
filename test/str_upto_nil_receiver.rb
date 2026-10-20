# String#upto on a receiver that turns out nil: nil has no upto, so CRuby
# raises NoMethodError naming upto, once the limit has been evaluated. The
# walk over (s..limit) the call becomes raised the Range's TypeError for a
# nil begin ("can't iterate from NilClass") instead.

def try(label)
  yield
rescue NoMethodError => e
  puts "#{label}: NoMethodError: #{e.message}"
rescue TypeError => e
  puts "#{label}: TypeError: #{e.message}"
end

def first_with(stations, initial) = stations.find { |s| s.start_with?(initial) }

def limit(code)
  puts "limit #{code}"
  code
end

line2 = ["Seongsu", "Kondae", "Guui"]
gate = first_with(line2, "Z")
try("block") { gate.upto("b") { |x| p x } }
try("exclusive") { gate.upto("b", true) { |x| p x } }
try("limit first") { gate.upto(limit("ICN")) { |x| p x } }
try("to_a") { p gate.upto("b").to_a }
try("map") { p gate.upto("b").map(&:upcase) }

def platforms(from, to)
  from.upto(to) { |x| print x, " " }
  puts
end
try("param") { platforms(first_with(line2, "Z"), "b") }
platforms(first_with(["Jayang", "aa"], "a"), "ad")

class Ferry
  attr_accessor :pier
  def pier_code=(code)
    @code = code
  end
  def codes(to) = @code.upto(to) { |x| print x, " " }
  def piers(to) = pier.upto(to).to_a
end
ferry = Ferry.new
try("ivar") { ferry.codes("GMP") }
try("reader") { p ferry.piers("Han River") }
ferry.pier_code = "GMN"
ferry.codes("GMP")
puts
ferry.pier = "Ha"
p ferry.piers("Hc")

stop = first_with(["Achasan", "Seongsu"], "A")
walked = stop.upto("Achasao") { |x| print x, " " }
puts
p walked
