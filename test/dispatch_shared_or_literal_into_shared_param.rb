# A call whose targets answer a slot's shared String or a String literal,
# handed on as a method's argument, hands on the object: the literal keeps
# one identity, and the shared String is the one its slot holds.
def keep(t)
  t << "!" unless t.frozen?
  t
end
class J; def zork = "j"; end
class K
  def initialize = @b = +"buf"
  def zork = @b
end
[K.new, J.new].reverse.each { |v| p keep(v.zork) }

class Note
  attr_reader :tag_name
  def initialize(tag_name) = @tag_name = tag_name
end
class Base
  def tag_name
    @tag_name ||= self.class.name
  end
  def add_note
    @notes ||= []
    @notes << Note.new(tag_name)
    nil
  end
  def notes = @notes
end
class Leaf < Base
  def tag_name = "Group/SectionName"
end
bs = Base.new
d = Leaf.new
[bs, d].each { |o| o.add_note; o.add_note }
other = Note.new(+"buf")
other.tag_name << "!"
p bs.notes.map(&:tag_name), d.notes.map(&:tag_name)
p bs.notes[0].tag_name.equal?(bs.notes[1].tag_name), d.notes[0].tag_name.equal?(d.notes[1].tag_name)
p other.tag_name
