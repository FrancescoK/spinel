# Two classes with the same leaf name in different modules, which the
# compiler renames apart: each annotation pins its own class and not the other.
module Left
  class Item
    def initialize
      @name = nil
    end

    attr_reader :name #: String?

    #: (untyped) -> untyped
    def weigh(x)
      x
    end
  end
end

module Right
  class Item
    def initialize
      @name = nil
    end

    attr_reader :name

    def weigh(x)
      x
    end
  end
end

p Left::Item.new.name
p Right::Item.new.name
p Left::Item.new.weigh(1)
p Right::Item.new.weigh(2)
