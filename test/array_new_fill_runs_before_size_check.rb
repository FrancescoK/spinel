# Array.new(n, v) runs v before it rejects a negative n, as CRuby evaluates
# both arguments first; the size check ran ahead of the fill (CodeRabbit on
# #10019). An object fill is one object in every slot.
class P; def initialize(v) = @v = v; attr_reader :v; end
$log = []
def fill(x) = ($log << x; x)
[-> { Array.new(-1, fill(P.new(1))) }, -> { Array.new(-2, fill(7)) }, -> { Array.new(-1, fill("s")) }].each do |f|
  begin
    f.call
  rescue ArgumentError => e
    puts e.message
  end
end
p $log.size
a = Array.new(3, P.new(5))
p a.map(&:v), a[0].equal?(a[2])
