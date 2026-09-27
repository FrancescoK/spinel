# A class-value `k.new(src, **)` whose argument is statically a Parsed, while
# the only static construction reaching the same initialize is a `super`
# passing a Synth from a subclass that is never instantiated.

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

class Special < Base
  def initialize = super(Synth.new(kind: 9, label: "special"))
end

MAPPERS = { 0 => Plain }.freeze

puts Base.from_parsed(Parsed.new(0, "parsed")).label
