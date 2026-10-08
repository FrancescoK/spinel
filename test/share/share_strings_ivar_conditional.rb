# An ivar arm already carries its shared String into a conditional's
# result slot, just as a local or a global arm does.
class ConditionalText
  def initialize(text)
    @text = text
  end

  def selected(flag)
    value = flag ? 'other' : @text
    value
  end
end
text = +'original'
holder = ConditionalText.new(text)
selected = holder.selected(false)
text << '!'
p selected
p holder.selected(true)
selected << '?'
p text
