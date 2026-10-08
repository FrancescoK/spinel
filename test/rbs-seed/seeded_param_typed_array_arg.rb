# A wider Array[untyped] parameter uses the existing element-boxing
# conversion, not a pointer reinterpretation (#6514).
# spinel: rbs-seed-run
module SeedArrayReader
  def self.join(list)
    list.join(" / ")
  end
end

puts SeedArrayReader.join(["book", "author"].reject { |x| x.empty? })
puts SeedArrayReader.join([13, 29].reject { |x| x < 20 })
puts SeedArrayReader.join([1.25, 2.5].reject { |x| x < 2.0 })
puts SeedArrayReader.join([])
puts SeedArrayReader.join(["left", "right"])
