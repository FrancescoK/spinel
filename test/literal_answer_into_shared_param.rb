# A method answering a String literal hands on the literal itself, which
# keeps one identity: into a parameter whose String is shared with
# another name and changed in place, through a dispatch beside a method
# answering a shared slot, and from a base class whose subclass alone
# defines the method.
class Note
  attr_reader :tag_name, :message
  def initialize(tag_name, message)
    @tag_name = tag_name
    @message = message
  end
end
class Base
  def tag_name
    @tag_name ||= self.class.name
  end
  def add_note(msg)
    @notes ||= []
    @notes << Note.new(tag_name, msg)
    nil
  end
  def notes = @notes
end
class Leaf < Base
  def tag_name
    "Group/SectionName"
  end
end
o = Leaf.new
o.add_note("m")
o.add_note("n")
b = +"buf"
other = Note.new(b, "x")
other.tag_name << "!"
a, z = o.notes
p a.tag_name, z.tag_name, a.tag_name.equal?(z.tag_name), other.tag_name, b

class Note2
  attr_reader :tag_name, :message
  def initialize(tag_name, message)
    @tag_name = tag_name
    @message = message
  end
end
class Base2
  def add_note(msg)
    @notes ||= []
    @notes << Note2.new(tag_name, msg)
    nil
  end
  def notes = @notes
end
class Leaf2 < Base2
  def tag_name
    "Group/SectionName"
  end
end
o = Leaf2.new
o.add_note("m")
o.add_note("n")
b = +"buf"
other = Note2.new(b, "x")
other.tag_name << "!"
a, z = o.notes
p a.tag_name, z.tag_name, a.tag_name.equal?(z.tag_name), a.tag_name.frozen?, other.tag_name, b

# A base class no instance of which is made: its own tag_name is never
# what the call answers.
class Base3
  def tag_name
    @tag_name ||= self.class.name
  end

  def add_note(msg)
    @notes ||= []
    @notes << Note2.new(tag_name, msg)
    nil
  end

  def notes = @notes
end

class Leaf3 < Base3
  def tag_name
    "Area/Thing"
  end
end

d3 = Leaf3.new
d3.add_note("p")
d3.add_note("q")
e, f = d3.notes
p e.tag_name, e.tag_name.equal?(f.tag_name)
