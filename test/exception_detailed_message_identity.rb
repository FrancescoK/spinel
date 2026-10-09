# spinel: share
# spinel: gc-minor
# Formatted exception text is fresh even when the stored message is shared.
class FormattedMessage < StandardError
  def message = "custom"
end
class FormattedToS < StandardError
  def to_s = +"override"
end
class FormattedInit < StandardError
  def initialize(message) = super(message + "!")
end

def detailed(source)
  raise source
rescue => error
  error.detailed_message
end

source = +"source"
text = detailed(source)
p text.equal?(source)
text << "!"
p source, text
source << "?"
p text

error = FormattedMessage.new("stored")
a = error.detailed_message
b = error.detailed_message
p a, a.equal?(b)
a << "!"
p b

source = +""
text = detailed(source)
p text, text.equal?(source), text.frozen?
text << "!"
p source
source = +"first\nsecond"
text = detailed(source)
p text, text.equal?(source)
text << "!"
p source

class OwnDetail < StandardError
  def detailed_message = +"own detail"
end
text = OwnDetail.new("stored").detailed_message
text << "!"
p text
