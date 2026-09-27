# A class-value `k.new(x, **)` passes x to the initialize it lands on, so a
# subclass's static `super(Synth...)` must not narrow that parameter to Synth.

class Parsed
  attr_reader :kind, :label

  def initialize(kind, label)
    @kind = kind
    @label = label
  end
end

Synth = Data.define(:kind, :label)

class Base
  attr_reader :label

  def self.from_parsed(src, **) = MAPPERS.fetch(src.kind).new(src, **)

  def initialize(src) = @label = src.label
end

class Plain < Base; end

class Forwarding < Base
  def initialize(src) = super
end

class Special < Base
  def initialize = super(Synth.new(kind: 9, label: "special"))
end

MAPPERS = { 0 => Plain, 1 => Forwarding }.freeze

puts Special.new.label
puts Base.from_parsed(Parsed.new(0, "parsed")).label
puts Base.from_parsed(Synth.new(kind: 0, label: "synth")).label
puts Base.from_parsed(Parsed.new(1, "forwarded parsed")).label
puts Base.from_parsed(Synth.new(kind: 1, label: "forwarded synth")).label

class Box
  attr_reader :v

  def initialize(v, tag: "t")
    @v = v
    @tag = tag
  end

  def show = "#{@v.inspect} #{@tag}"
end

class One < Box
  def initialize = super(1)
end

class Holder
  def initialize(k) = @k = k
  def make(x, **) = @k.new(x, **)
end

puts One.new.show
puts Holder.new(Box).make(:sym, tag: "x").show
puts Holder.new(Box).make("str").show
