# A demanded call that returns a new String wraps its bytes in a handle.
# An attribute reader still hands over the handle its instance already owns.
class FreshElement
  attr_reader :saved
  def initialize = (@saved = +"saved")
  def text = "fresh #{@saved}"
end

source = FreshElement.new
values = [source.text, source.saved]
values.each { |value| value << "!" }
p values
p source.saved
p source.text
