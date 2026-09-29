# a def in the including class overrides a module's attr_reader for the
# module's own methods, as it does for outside callers
module Addressable
  attr_reader :start, :length
  def addressable_at(start = 0, length: 16)
    @start = start
    @length = length
  end
  def range = start..(start + (length - 1))
end
class Ram
  include Addressable
  def initialize = addressable_at(0x100, length: 4)
end
class Bank
  include Addressable
  STARTS = [0xc000, 0x8000]
  def initialize(sel) = (addressable_at(0, length: 8); @sel = sel)
  def start = STARTS[@sel]
end
p Ram.new.range, Bank.new(1).range, Bank.new(0).start

module Twice
  attr_reader :n
  def twice = n * 2
end
class Plain
  include Twice
  def initialize = @n = 1
end
class Own
  include Twice
  def initialize = @n = 1
  def n = 50
end
p Plain.new.twice, Own.new.twice
