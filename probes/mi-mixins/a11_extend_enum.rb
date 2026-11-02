class C
  extend Enumerable
  def self.each
    yield 1; yield 2; yield 3
  end
end
p C.map { |x| x * 2 }
p C.first
p C.include?(2)
p C.each_slice(2).to_a
p C.is_a?(Enumerable)
