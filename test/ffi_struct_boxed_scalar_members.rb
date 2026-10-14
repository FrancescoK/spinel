# spinel: not-cruby -- the spinel-native FFI DSL; the .expected is authored
# ffi_struct members typed :float, :double and :bool take a boxed value:
# converted and checked as an ffi_func argument is (a boxed Float went in
# raw and the C did not compile; a boxed true was read as an Integer and
# raised), and nil raises TypeError (#9092).
module A
  State = Struct.new(:v)
  def self.init = State.new(0.5)
  def self.f(s) = s.v
end
module B
  State = Struct.new(:v)
  def self.init = State.new(2)
  def self.f(s) = s.v
end
def value(g, s) = g.f(s)
module M
  ffi_struct :Point, [[:x, :float], [:y, :double], [:on, :bool]]
end
g = ENV["B"] ? B : A
poly = value(g, g.init)
pt = M.Point_new
M.Point_set_x(pt, poly)
M.Point_set_y(pt, poly)
p M.Point_get_x(pt), M.Point_get_y(pt)
flags = [true, false, 1, 0]
f = flags[ARGV.size]
M.Point_set_on(pt, f)
p M.Point_get_on(pt)
begin
  M.Point_set_y(pt, nil)
rescue TypeError => e
  puts "nil -> #{e.message}"
end
