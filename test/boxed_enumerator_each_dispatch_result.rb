# A user-defined each makes boxed builtin calls use the runtime proc driver.
class OtherEach
  def each
    yield 99
    :other
  end
end
p OtherEach.new.each { |q| q }
e = [3.5, 1.5].each
e = nil if ARGV.size > 3
p e.each { |q| p q }
g = Enumerator.new do |y|
  y << 7
  :finished
end
g = nil if ARGV.size > 3
p g.each { |q| p q }
p g.each { |q| q }
