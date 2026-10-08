# A reader on a boxed receiver hands on its shared field, including identity reads.
Box = Struct.new(:text)
class Note
  attr_reader :text
  alias content text
  def initialize(text)
    @text = text
  end
end
box = [Box.new(+"a\0b"), 1][0]
text = box.text
text << "x" * 100
p [text.size, box.text.size, text[0, 3]]
p box.text.equal?(box.text)
p box.text.object_id == text.object_id
note = [Note.new(+"c"), 1][0]
copy = note.content
copy << "y" * 100
p [copy.size, note.text.size]
p note.text.equal?(copy)
p note.content.equal?(note.text)

# Rebinding the destination leaves the field's String in place.
copy = +"new"
p [copy, note.text.size]
frozen_box = [Box.new("fixed"), 1][0]
p frozen_box.text.frozen?
begin
  value = frozen_box.text
  value << "!"
rescue FrozenError
  p frozen_box.text
end
