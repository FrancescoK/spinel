class Bank
  def initialize(data = Array.new(4, 0))
    @data = data
  end

  def poke(addr, value)
    @data[addr & 3] = value
  end
end

class WriteOnly < Bank
  def initialize(data, reader)
    super(data)
    @reader = reader
  end
end

class Cart
  def initialize = @ram = Array.new(2) { Array.new(4, 0) }
  def window = WriteOnly.new(@ram[1], Bank.new)
  def row(i) = @ram[i]
end

class Bus
  def initialize = @pages = []
  def map(bank) = @pages << bank
  def poke(addr, value) = @pages[0].poke(addr, value)
end

class Note
  def self.mark(bank) = bank.poke(1, "note")
end

cart = Cart.new
bus = Bus.new
bus.map(cart.window)
bus.poke(2, 7)
p cart.row(1)
spare = Bank.new
Note.mark(spare)
