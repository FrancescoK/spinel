# A local written from a call whose answer comes a round later
# (`input = root`) is not guessed a Hash from `input["k"]` meanwhile when a
# class of the program defines `[]`: the guess typed the block over
# `input["k"].each` boxed for good, a dispatch where a direct call does
# (#8401). A Hash read on a local with no such call is unchanged.
class Box
  def initialize(h)
    @h = h
  end

  def [](name)
    Box.new(@h + name.length)
  end

  def each
    i = 0
    while i < 3
      yield Box.new(@h + i)
      i += 1
    end
  end

  def to_i
    @h
  end
end

def root = Box.new(1)

def run
  input = root
  total = 0
  input["cart"].each { |line| total += line["quantity"].to_i }
  total
end

p run
h = {}
p h["missing"]
h["k"] = 2
p h["k"]
