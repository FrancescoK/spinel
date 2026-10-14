# spinel: not-cruby -- the spinel-native FFI DSL; the .expected is authored
# A native binding's :float, :bool and :string? parameters take a boxed value,
# converted and checked (it went in raw and the C did not compile), and a
# nil :float or :bool raises TypeError rather than passing 0.0 or false;
# a :string? takes nil as NULL (#9092).
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
module N
  ffi_source <<~C
    struct my_vec_s { double x; int on; const char *s; };
    static void my_vec_scan(void *p) { (void)p; }
    my_vec *my_vec_new(sp_int cls_id, double x) {
      my_vec *v = (my_vec *)sp_gc_alloc(sizeof(my_vec), NULL, my_vec_scan);
      (void)cls_id; v->x = x; v->on = 0; v->s = NULL;
      return v;
    }
    double my_vec_x(my_vec *v) { return v->x; }
    my_vec *my_vec_set_x(my_vec *v, double x) { v->x = x; return v; }
    my_vec *my_vec_set_on(my_vec *v, sp_bool on) { v->on = on; return v; }
    sp_bool my_vec_on(my_vec *v) { return v->on; }
    my_vec *my_vec_set_s(my_vec *v, const char *s) { v->s = s; return v; }
    const char *my_vec_s(my_vec *v) { return v->s; }
  C
  native_struct "Vec", "my_vec"
  native_new [:float], "my_vec_new"
  native_method :x, [], :float, "my_vec_x"
  native_method :set_x, [:float], :self, "my_vec_set_x"
  native_method :set_on, [:bool], :self, "my_vec_set_on"
  native_method :on, [], :bool, "my_vec_on"
  native_method :set_s, [:string?], :self, "my_vec_set_s"
  native_method :s, [], :string?, "my_vec_s"
end
g = ENV["B"] ? B : A
poly = value(g, g.init)
v = N::Vec.new(poly)
p v.x
v.set_x(poly)
p v.x
bools = [true, false]
v.set_on(bools[ARGV.size])
p v.on
strs = ["hi", nil]
v.set_s(strs[ARGV.size])
p v.s
v.set_s(strs[1])
p v.s
begin
  N::Vec.new(nil)
rescue TypeError => e
  puts "nil -> #{e.message}"
end
begin
  v.set_on(nil)
rescue TypeError => e
  puts "nil bool -> #{e.message}"
end
