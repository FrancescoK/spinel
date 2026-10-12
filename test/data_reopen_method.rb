# A method defined in a reopened Data is inherited by every Data.define
# class, and a data class's own method still overrides it.
class Data
  def as_json
    to_h
  end

  def label
    "data"
  end
end

Coord = Data.define(:lat, :lng)
Money = Data.define(:amount) do
  def label
    "money #{amount}"
  end
end

p Coord.new(lat: 1, lng: 2).as_json
p Money.new(amount: 3).as_json
puts Coord.new(lat: 1, lng: 2).label
puts Money.new(amount: 3).label
