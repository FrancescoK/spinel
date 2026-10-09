def ev(o, m, *a, **) = o.send(m, *a, **)
def pub(o, m, *a, **k) = o.public_send(m, *a, **k)
def fwd_byte(o, &b) = o.send(:each_byte, &b)
def pub_byte(o, &b) = o.public_send(:each_byte, &b)

x = [1, "ab"][1]
r = []
fwd_byte(x) { |c| r << c }
pub_byte(x) { |c| r << c }
p r

m = [:each_byte, :size][0]
q = []
x.send(m) { |c| q << c }
p q

n = [:each_line, :size][0]
s = "a\nb\n"
lines = []
s.send(n, chomp: true) { |l| lines << l }
p lines

[{a: 1}, [1], (1..2)].each do |o|
  begin
    "ab" < o
  rescue ArgumentError => e
    p e.message
  end
end

p ev(1, :step, by: 2, to: 5).to_a
p pub(1, :step, by: 2, to: 5).to_a
p ev(1, :step, 5, 2).to_a
h = {by: 3, to: 10}
p 1.step(**h).to_a
begin
  ev(1, :step, by: 2, foo: 1)
rescue ArgumentError => e
  p e.message
end

p ev([1, 2, 3], :sample, random: Random.new(1)).class
p [1, 2, 3].include?(pub([1, 2, 3], :sample, random: Random.new(2)))
p ev([3, 1, 2], :shuffle, random: Random.new(1)).sort
p ev([1, 2, 3], :sample).class
begin
  ev([1, 2], :sample, random: 5)
rescue NoMethodError => e
  p e.class
end
