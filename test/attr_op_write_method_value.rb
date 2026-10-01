class Shop
  attr_accessor :customers, :label

  def initialize
    @customers = 0
    @label = "shop"
  end

  def arrive
    self.customers += 1
  end

  def leave = self.customers -= 1

  def rename(suffix)
    self.label += suffix
  end
end

shop = Shop.new
p shop.arrive
p shop.arrive
p shop.leave
p shop.rename("!")
p [:arrive, :leave].map { |m| shop.send(m) }
p [shop.customers, shop.label]
