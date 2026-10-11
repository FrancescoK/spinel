# spinel: reject-hash-string
# spinel: reject-share
# A Hash value passed to a writer that stores it into an ivar another
# method appends to: CRuby appends to the Hash's own String. A Hash's
# values hold copies here, so the store is refused with the Hash-values
# message rather than compiled into C that does not build (#8525).
class Widget
  def []=(key, value)
    @label = value
  end

  def shout
    @label << "!"
  end
end

widget = Widget.new
source = { "label" => +"Ada" }
source.each do |key, value|
  widget[key] = value
end
p widget.shout
p source["label"]
