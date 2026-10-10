# spinel: rbs-seed-run
# A String slot an --rbs seed pins on a subclass's writer, which an
# ancestor's method also reads, takes a shared String handle (a Hash value
# appended in place) in the whole family: the promotion stopped at the
# subclass and the layout check refused the two classes (#8390).
class PinBase
  def key
    @id
  end
end

class PinWidget < PinBase
  def id=(value)
    @id = value
  end
end

class PinOther < PinBase
  def initialize = @id = "other"
end

h = { "id" => String.new }
h["id"] << "w1"
w = PinWidget.new
w.id = h["id"]
puts w.key
puts PinOther.new.key
