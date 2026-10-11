# An empty `[]` default for a parameter callers pass an Array of one class:
# the default is built as that object array, so a call that leaves it out,
# and a push of another kind into one, both still work.
Section = Data.define(:name, :data)

class Container
  def initialize(sections = [])
    @sections = sections
  end

  attr_reader :sections

  def add(section) = @sections << section

  class Reader
    def initialize(bytes)
      @bytes = bytes
      @pos = 0
    end

    def container
      sections = []
      sections << section while @pos < @bytes.bytesize
      Container.new(sections)
    end

    def take(length)
      @bytes.byteslice(@pos, length).tap { @pos += length }
    end

    def section
      length = take(1).unpack1("C")
      Section.new(name: "s", data: take(length))
    end
  end
end

class Bag
  def initialize(items = [])
    @items = items
  end

  def add(item) = @items << item
  def size = @items.size
end

p Container::Reader.new("\x02ab\x01c".b).container.sections.map(&:data)
empty = Container.new
p empty.sections
empty.add(Section.new(name: "x", data: "z"))
p empty.sections.map(&:name)
b = Bag.new([Section.new(name: "a", data: "b")])
b.add("not a section")
p b.size
p Bag.new.size
