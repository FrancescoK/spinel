# Forwardable takes a String wherever it takes a Symbol, and a Module as the
# accessor: the accessor is source text pasted in front of the call.
require "forwardable"

class Resolver
  def name = "resolver"
  def color = Painter.new
end

class Painter
  def red(s) = "red:#{s}"
  def ok? = true
end

module ColorParser
  def self.parse(s) = s.split(",")
end

class Pastel
  extend Forwardable
  def_delegators "@resolver", :name
  def_delegators "@resolver.color", :red, "ok?"
  def_delegators ColorParser, :parse
  def_delegators :@items, "size", "first"
  def_delegator "@items", "last", "final"
  def_delegator :@resolver, :name, "label"
  WORDS = %w[min max].freeze
  def_delegators :@items, *WORDS
  QUOTED = ["sum", 'count'].freeze
  def_delegators :@items, *QUOTED

  def initialize
    @resolver = Resolver.new
    @items = [3, 1, 2]
  end
end

pa = Pastel.new
p pa.name
p pa.red("x")
p pa.ok?
p pa.parse("a,b")
p pa.size, pa.first, pa.final
p pa.label
p pa.min, pa.max, pa.sum, pa.count
