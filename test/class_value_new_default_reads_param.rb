class Inline
  def self.new(rdoc, reference = rdoc)
    if self === rdoc and reference.equal? rdoc
      rdoc
    else
      super
    end
  end

  attr_reader :rdoc, :reference

  def initialize(rdoc, reference)
    @rdoc = rdoc
    @reference = reference
  end
end

class Other
  attr_reader :x

  def initialize(x) = @x = x
end

[Inline, Other].each do |k|
  o = k.new("a")
  p o.class
end

kinds = [Inline, Other]
p kinds.map { |k| k.new("b").class }
i = Inline.new("c")
p i.reference
p Inline.new(i).equal?(i)

class Tag
  def self.new(name, label = name.upcase, size: label.size)
    super(name, label, size)
  end

  attr_reader :name, :label, :size

  def initialize(name, label, size)
    @name = name
    @label = label
    @size = size
  end
end

[Tag, Other].each do |k|
  t = k.new("ok")
  p t.class
  p [t.name, t.label, t.size] if t.is_a?(Tag)
end
[Tag, Other].each do |k|
  next unless k == Tag
  t = k.new("hey", size: 9)
  p [t.name, t.label, t.size]
end
