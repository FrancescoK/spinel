module R
  def self.each
    yield :a; yield :b
  end
  p((count rescue :nomethod))
  extend Enumerable
  p count
end
p R.to_a
