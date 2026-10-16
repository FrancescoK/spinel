# spinel: not-cruby -- the spinel-native FFI DSL; the .expected is authored
# A multiple assignment to the writers a native class binds (`native_method
# :x=`) calls each one, as the single assignments do: it was refused,
# "multiple assignment call target no writer" (#9202). An Integer element
# goes into a :float writer as its Float, and a plain Ruby class's writers
# beside it are still called.
module Native
  ffi_source <<~C
    struct probe_vec2_s { double x; double y; };
    static void probe_vec2_scan(void *p) { (void)p; }
    probe_vec2 *probe_vec2_new(sp_int cls_id) {
      probe_vec2 *v = (probe_vec2 *)sp_gc_alloc(sizeof(probe_vec2), NULL, probe_vec2_scan);
      (void)cls_id; v->x = 0.0; v->y = 0.0; return v;
    }
    double probe_vec2_set_x(probe_vec2 *v, double x) { v->x = x; return x; }
    double probe_vec2_set_y(probe_vec2 *v, double y) { v->y = y; return y; }
    double probe_vec2_x(probe_vec2 *v) { return v->x; }
    double probe_vec2_y(probe_vec2 *v) { return v->y; }
  C
  native_struct "Vec2", "probe_vec2"
  native_new [], "probe_vec2_new"
  native_method :x=, [:float], :float, "probe_vec2_set_x"
  native_method :y=, [:float], :float, "probe_vec2_set_y"
  native_method :x, [], :float, "probe_vec2_x"
  native_method :y, [], :float, "probe_vec2_y"
end

v = Native::Vec2.new
v.x, v.y = 1.0, 2.0
puts "#{v.x} #{v.y}"
v.x, v.y = 3, 4.5
puts "#{v.x} #{v.y}"
a, v.y = 7, v.x + 1
puts "#{a} #{v.y}"

class Plain
  def a=(value)
    @a = value
  end

  def b=(value)
    @b = value
  end

  def show = "#{@a},#{@b}"
end

q = Plain.new
q.a, q.b = 3, 4
puts q.show
