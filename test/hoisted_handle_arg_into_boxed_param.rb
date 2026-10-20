# A String method answering its slot's shared String, handed to a boxed
# parameter beside a later argument: the argument runs first into a temp
# of the handle, which the boxed parameter takes as it is.
class Note
  attr_reader :tag_name, :message
  def initialize(tag_name, message)
    @tag_name = tag_name
    @message = message
  end
end
class Base
  def self.tag_name
    parts = name.split("::")
    "#{parts[-2]}/#{parts[-1]}"
  end
  def tag_name
    @tag_name ||= self.class.tag_name
  end
  def add_note(msg)
    @notes ||= []
    @notes << Note.new(tag_name, msg)
    nil
  end
  def notes = @notes
end
module Kind
  class Foo < Base
  end
end
o = Kind::Foo.new
o.add_note("m")
b = +"buf"
other = Note.new(b, "n")
other.tag_name << "!"
p o.notes[0].tag_name, other.tag_name, b
