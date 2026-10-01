# A class that overrides respond_to? (as Rack::Lint's body wrapper does) and
# falls back to super. Its own instances answer through it; every other
# value, boxed or typed, still answers respond_to? as it would without it.
require "stringio"

class Wrap
  def initialize(b) = @b = b

  def respond_to?(name, *)
    if name == :each
      @b.respond_to?(name)
    else
      super
    end
  end

  def each = @b.each { |x| yield x }
  private def hidden = 2
end

vals = [StringIO.new("x"), "str", [1], { a: 1 }, 5, nil, Wrap.new([1]), Wrap.new(3)]
vals.each do |v|
  p [v.respond_to?(:read), v.respond_to?(:each), v.respond_to?(:upcase), v.respond_to?(:nope)]
end

env = { "rack.input" => StringIO.new("x"), "n" => 1 }
input = env["rack.input"]
p %i[gets each read rewind nope].map { |m| input.respond_to?(m) }

w = Wrap.new([1])
p w.respond_to?(:hidden), w.respond_to?(:hidden, true), w.respond_to?(:each), w.respond_to?(:to_s)
p Wrap.new(3).respond_to?(:each), 3.respond_to?(:each)
x = [3, "s"][0]
m = :upcase
p x.respond_to?(m), [3, "s"][1].respond_to?(m)
