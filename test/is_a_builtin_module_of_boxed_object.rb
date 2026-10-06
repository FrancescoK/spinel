class Version
  include Comparable

  def <=>(other)
    0
  end
end

class Shelf
  include Enumerable

  def each
    yield 1
  end
end

items = [Version.new, Shelf.new, 1, "text", nil]
items.each do |item|
  puts "#{item.class}: #{item.is_a?(Comparable)} #{item.is_a?(Enumerable)} #{Comparable === item}"
end
