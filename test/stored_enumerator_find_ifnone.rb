fb = -> { :none }
g = [1, 2, 3].find(fb)
p g.each { |x| x > 5 }
p g.each { |x| x > 1 }
p g.class
p g.to_a
calls = 0
lz = [4, 5].find(-> { calls += 1; :fallback })
p calls
p lz.each { |x| x > 9 }
p calls
p lz.each { |x| x == 5 }
p calls
rg = (1..4).find(proc { 0 })
p rg.each { |x| x > 9 }
p rg.each { |x| x.even? }
dt = [7, 8].detect(-> { :nope })
p dt.each { |x| x > 9 }
[1].each do
  inner = [3, 4].find(-> { :inner_none })
  p inner.each { |x| x > 3 }
  p inner.each { |x| x > 4 }
end
def made_fallback
  puts "made fallback"
  -> { :none }
end
absent = nil
sn = absent&.find(made_fallback)
p sn
begin
  sn.each { |x| x }
rescue NoMethodError => ex
  puts ex.message
end
