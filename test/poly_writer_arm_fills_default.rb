# A writer called on a boxed receiver dispatches per class. The arm
# for a writer with an optional parameter passes that default too.
class Button
  attr_accessor :text
end

class TextField
  def text=(value, trigger_changed = true)
    @text = value
    puts "field #{value} #{trigger_changed}"
  end
end

class Label
  def text=(new_text)
    puts "label #{new_text}"
  end
end

class MenuText
  attr_reader :text_id

  def initialize
    @text_id = :title
  end
end

components = [Button.new, TextField.new, Label.new, MenuText.new, 3]
components.each do |c|
  c.text = "hi" if c.respond_to?(:text=)
end
p components[0].text
