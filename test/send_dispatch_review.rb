def hv(tag, h) = (puts "eval #{tag}"; h)

a = nil
p a&.sample(**hv(:sample_nil, {random: Random.new(1)}))
p a&.shuffle(**hv(:shuffle_nil, {random: Random.new(1)}))
n = nil
p n&.step(**hv(:step_nil, {by: 2, to: 5}))
b = [7]
p b&.sample(**hv(:sample_some, {random: Random.new(1)}))
p b&.shuffle(**hv(:shuffle_some, {random: Random.new(1)}))
m = 1
p m&.step(**hv(:step_some, {by: 2, to: 5}))&.to_a
s = nil
p s&.lines(**hv(:lines_nil, {chomp: true}))
t = "a\nb\n"
p t&.lines(**hv(:lines_some, {chomp: true}))

begin; p "a" < []; rescue ArgumentError => e; puts e.message; end
begin; p "a" <= {}; rescue ArgumentError => e; puts e.message; end
begin; p "a" > []; rescue ArgumentError => e; puts e.message; end
begin; p "a" >= {}; rescue ArgumentError => e; puts e.message; end
begin; p "a" < {}; rescue ArgumentError => e; puts e.message; end
begin; p "a" >= []; rescue ArgumentError => e; puts e.message; end
%i[< <= > >=].each do |op|
  [[], {}].each do |o|
    begin
      p "a".send(op, o)
    rescue ArgumentError => e
      puts "#{op} #{e.message}"
    end
  end
end
x = []
y = {}
begin; p "a" < x; rescue ArgumentError => e; puts e.message; end
begin; p "a" >= y; rescue ArgumentError => e; puts e.message; end
p "a" < "b"
