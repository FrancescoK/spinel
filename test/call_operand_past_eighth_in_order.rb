# A call's ninth operand and those after it run in their place too: the
# receiver counts as an operand, so a Data of nine members read from a
# stream read its last member first, and with no receiver the nine values
# were left to C's order, which gcc runs right to left.

class Input
  def initialize(values)
    @values = values
    @at = 0
  end

  def int
    value = @values[@at]
    @at += 1
    value
  end

  def boolean? = int == 1

  def schema = 6
end

MODELS = %i[a b c].freeze
KERNALS = %i[c64 pet].freeze
BOARDS = %i[c64 pet64].freeze
Setup = Data.define(:vic_model, :cia_model, :sid_model, :region, :ram_expansion, :reu, :kernal, :datasette, :board)

class Setup
  def self.reu(size) = size.zero? ? nil : size

  def self.ram_expansion(name) = name == :none ? nil : name

  def self.read(input)
    new(vic_model: MODELS.fetch(input.int), cia_model: MODELS.fetch(input.int),
        sid_model: MODELS.fetch(input.int), region: MODELS.fetch(input.int),
        ram_expansion: ram_expansion(MODELS.fetch(input.int)), reu: reu(input.int),
        kernal: input.schema > 3 ? KERNALS.fetch(input.int) : :c64,
        datasette: input.schema > 3 ? input.boolean? : true,
        board: input.schema > 5 ? BOARDS.fetch(input.int) : :c64)
  rescue IndexError
    raise ArgumentError, "the state names a model badline doesn't know"
  end
end

Wide = Data.define(:a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k)

class Box
  def take(*values) = values
end

p Setup.read(Input.new([0, 1, 2, 0, 1, 0, 0, 1, 0]))
r = Input.new((1..20).to_a)
p Wide.new(a: r.int, b: r.int, c: r.int, d: r.int, e: r.int, f: r.int, g: r.int, h: r.int, i: r.int,
           j: r.int, k: r.int)
r = Input.new((1..20).to_a)
p Box.new.take(r.int, r.int, r.int, r.int, r.int, r.int, r.int, r.int, r.int, r.int)
