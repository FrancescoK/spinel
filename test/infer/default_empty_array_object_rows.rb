# A parameter with an empty `[]` default that every caller passes an Array
# of one class: narrow_object_arrays narrows it to that object array, and
# infer_default_param_types merged the default -- the untyped container --
# back in, boxing it, every round. The typed-array kinds already build the
# empty default as the callers' kind; an object array did not, and the
# fixpoint ran to its round cap.
Section = Data.define(:name, :data)

class Container
  def initialize(sections = [])
    @sections = sections
  end

  attr_reader :sections

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

p Container::Reader.new("\x02ab\x01c".b).container.sections.map(&:data)
