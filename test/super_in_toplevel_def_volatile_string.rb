# A super in a top-level def is in no class, and has no target when the
# volatility of a String a rescue keeps live is lent through each super:
# the program compiles. The defs are never called (CRuby raises
# NoMethodError from them).

def describe(place) = super
def describe_line(place, line) = super(place)

def arrival(station)
  note = "via the Han River"
  begin
    note = "#{station} station"
    raise ArgumentError, "closed for repairs" if station == "Guui"
  rescue ArgumentError => e
    note = "#{note}, #{e.message}"
  end
  note
end

puts arrival("Jayang")
puts arrival("Guui")
puts arrival("Konkuk Univ.")
