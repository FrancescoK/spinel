# A send and a respond_to? whose method name only the run time knows
# dispatch over the program's method names by the name's symbol. With one
# arm per name, the `if ... else if` chain nested a level per name, and a
# program with a few thousand names (a Rails app) took clang past its
# stack; the dispatch is a switch over the symbol now. Each arm, the miss
# and the answer of respond_to? are as before.

class Cart
  def total = 30
  def count = 3
  def label = "cart"
end
class Order
  def total = 100
  def ship = :shipped
end
NAMES = %i[total count label ship missing]

class Hook
  def initialize(m) = @m = m
  def run(target) = target.send(@m)
  def able?(target) = target.respond_to?(@m)
end

[Cart.new, Order.new].each do |t|
  NAMES.each do |nm|
    h = Hook.new(nm)
    begin
      p [t.class, nm, h.able?(t), h.run(t)]
    rescue NoMethodError => e
      p [t.class, nm, h.able?(t), e.message]
    end
  end
end
