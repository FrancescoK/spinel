# spinel: not-cruby -- the spinel-native FFI DSL; the .expected is authored
# A native method answering :self, reached through a receiver that may be
# either of two native structs defining it, answers the struct it returned
# (the poly dispatch dropped the result and answered nil).
module N
  ffi_source <<~C
    struct my_box_s { sp_int n; };
    static void my_box_scan(void *p) { (void)p; }
    my_box *my_box_new(sp_int cls_id) {
      my_box *b = (my_box *)sp_gc_alloc(sizeof(my_box), NULL, my_box_scan);
      (void)cls_id; b->n = 1;
      return b;
    }
    my_box *my_box_next(my_box *b) {
      my_box *c = my_box_new(0);
      c->n = b->n + 1;
      return c;
    }
    sp_int my_box_n(my_box *b) { return b->n; }
    struct my_bag_s { sp_int n; };
    static void my_bag_scan(void *p) { (void)p; }
    my_bag *my_bag_new(sp_int cls_id) {
      my_bag *b = (my_bag *)sp_gc_alloc(sizeof(my_bag), NULL, my_bag_scan);
      (void)cls_id; b->n = 10;
      return b;
    }
    my_bag *my_bag_next(my_bag *b) {
      my_bag *c = my_bag_new(0);
      c->n = b->n + 10;
      return c;
    }
    sp_int my_bag_n(my_bag *b) { return b->n; }
  C
  native_struct "Box", "my_box"
  native_new [], "my_box_new"
  native_method :child, [], :self, "my_box_next"
  native_method :n, [], :int, "my_box_n"
end
module M
  native_struct "Bag", "my_bag"
  native_new [], "my_bag_new"
  native_method :child, [], :self, "my_bag_next"
  native_method :n, [], :int, "my_bag_n"
end
def step(r) = r.child
[N::Box.new, M::Bag.new].each do |r|
  s = step(r)
  p s.nil?
  p s.n
end
