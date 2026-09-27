# `new(src)` and `self.new(src, **)` in a class method construct the class the
# method is called on, so they type its initialize the way a class-value `new`
# does, beside a subclass's static `super(Synth...)`.

class Parsed
  attr_reader :name

  def initialize(name) = @name = name
end

Synth = Data.define(:name)

class Base
  attr_reader :name

  def self.build(src) = new(src)
  def self.build_kw(src, **) = self.new(src, **)

  def initialize(src) = @name = src.name
end

class Plain < Base; end

class Special < Base
  def initialize = super(Synth.new(name: "special"))
end

puts Special.new.name
puts Plain.build(Parsed.new("bare new")).name
puts Plain.build_kw(Parsed.new("self.new with **")).name
