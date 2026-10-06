#!/usr/bin/env bash
# Exercise the cost tools (#7501): `spinel --dump-repr` on a small program,
# and tools/repr_diff.sh, tools/c_costs.sh and tools/alloc_diff.sh against
# stand-in compilers whose output is fixed here, so each summary is known.
#
#   tools/cost_tools_test.sh dump|repr|costs|costs-live|alloc
set -eu
ROOT=$(pwd)
T=$(mktemp -d "${TMPDIR:-/tmp}/spinel-cost-tools-test.XXXXXX")
trap 'rm -rf "$T"' EXIT
cd "$T"

# A stand-in compiler: `--dump-repr P` prints P.<side>.repr (and is
# refused once a file no-dump-repr exists), `-S` prints
# P.<side>.c, `P -o OUT` writes a program that prints P.<side>.out,
# writes P.<side>.alloc as its allocation report and exits with
# P.<side>.rc (else 0); the new side's program also reports one allocation
# per argument it was given. <side> is the name the stand-in is invoked by.
mock() {
  cat > "$T/$1" <<'MOCK'
#!/usr/bin/env bash
side=$(basename "$0"); mode=; prog=; out=
while [ "$#" -gt 0 ]; do
  case "$1" in --dump-repr) mode=repr;; -S) mode=c;; -o) out=$2; shift;; *.rb) prog=$1;; esac
  shift
done
case "$mode" in
  repr) [ -f "$PWD/no-dump-repr" ] && { echo "spinel: unknown option '--dump-repr'" >&2; exit 1; }
        [ -f "$prog.$side.repr" ] && cat "$prog.$side.repr"; exit 0;;
  c) cat "$prog.$side.c";;
  *) rc=0; [ -f "$prog.$side.rc" ] && rc=$(cat "$prog.$side.rc")
     printf '#!/bin/sh\ncat "%s"\n[ -f "%s" ] && cp "%s" "$SPINEL_ALLOC_REPORT"\n[ %s = new ] && [ $# -gt 0 ] && echo "alloc;Args $#" >> "$SPINEL_ALLOC_REPORT"\nexit %s\n' \
       "$PWD/$prog.$side.out" "$PWD/$prog.$side.alloc" "$PWD/$prog.$side.alloc" "$side" "$rc" > "$out"
     chmod +x "$out";;
esac
MOCK
  chmod +x "$T/$1"
}
mock ref
mock new

case "$1" in
dump)
  cat > shapes.rb <<'RUBY'
class Buf
  attr_reader :s
  def initialize(n)
    @s = "\0".b * n
    @s.setbyte(0, 65)
    @hits = 0
  end
  def peek
    t = @s
    @hits += 1
    t.getbyte(0)
  end
end
Pt = Struct.new(:x, :y)
$log = ["start"]
LIMIT = 3
def find(a, x)
  a.index(x)
end
mixed = [1, "two"].first
range = (1..LIMIT)
buf = Buf.new(4)
p buf.peek, mixed, range, $log.size, find([5, 6], 6), Pt.new(1, 2).x
RUBY
  "$ROOT/bin/spinel" --dump-repr shapes.rb
  # the same compiler on both sides: nothing moves
  bash "$ROOT/tools/repr_diff.sh" "$ROOT/bin/spinel" "$ROOT/bin/spinel" shapes.rb
  ;;
repr)
  # a String ivar that becomes the shared handle, a local that becomes
  # boxed, a Range that leaves its by-value layout, a slot only the new
  # compiler has, and one that does not change; c.rb's slot only the new
  # compiler has, beside an empty dump, and d/e.rb and d_e.rb, two paths
  # that differ only in a slash
  printf 'x\n' > a.rb; printf 'y\n' > b.rb; printf 'z\n' > c.rb
  mkdir d; printf 'w\n' > d/e.rb; printf 'v\n' > d_e.rb
  cat > a.rb.ref.repr <<'EOF'
ivar Holder @buf: ptr ty=string
local <main> r: struct ty=range
local Holder#run v: scalar ty=int
param Holder.use s: ptr ty=string
EOF
  cat > a.rb.new.repr <<'EOF'
ivar Holder @buf: strbuf ty=strbuf handle
local <main> r: ptr ty=poly_array
local Holder#run t: scalar ty=int
local Holder#run v: boxed ty=poly
param Holder.use s: ptr ty=string
EOF
  cp a.rb.ref.repr b.rb.ref.repr; cp a.rb.ref.repr b.rb.new.repr
  printf 'local <main> z: scalar ty=int\n' > c.rb.new.repr
  printf 'local <main> t: ptr ty=string\n' > d/e.rb.ref.repr
  printf 'local <main> t: strbuf ty=strbuf\n' > d/e.rb.new.repr
  cp a.rb.ref.repr d_e.rb.ref.repr; cp a.rb.ref.repr d_e.rb.new.repr
  bash "$ROOT/tools/repr_diff.sh" ./ref ./new a.rb b.rb c.rb d/e.rb d_e.rb
  # a compiler without --dump-repr: both sides compare their C instead
  cat > a.rb.ref.c <<'EOF'
struct sp_Holder_s {
  sp_int cls_id;
  const char * iv_buf;
};
static sp_RbVal gv_log = {0};
static sp_int sp_Holder_s_use(const char * lv_s, sp_int lv_i) {
    sp_Range lv_r = {0};
  return 0;
}
EOF
  sed -e 's/const char \* iv_buf/sp_String * iv_buf/' -e 's/sp_Range lv_r = {0}/sp_Range * lv_r = NULL/' \
      -e 's/sp_int lv_i)/sp_RbVal lv_i)/' a.rb.ref.c > a.rb.new.c
  touch no-dump-repr
  bash "$ROOT/tools/repr_diff.sh" ./ref ./new a.rb
  ;;
costs)
  # a snapshot copy in a loop body, one in a function only a loop calls,
  # one outside any loop; a dup in a one-statement loop body; a dispatch
  # whose prototype and definition are not calls; a GC root registered per
  # iteration; braces and a call's name
  # inside a string literal; a `while (0)`, which is no loop
  cat > ref.c <<'EOF'
static sp_RbVal sp_pd_0(sp_RbVal _t0);
static sp_int sp_use(const char * lv_s) {
  return sp_str_getbyte(lv_s, 0);
}
static sp_int sp_run(sp_Holder *self, sp_int lv_n) {
  sp_int lv_t = 0;
  for (sp_int _t1 = 0; _t1 < lv_n; _t1++) {
    lv_t = sp_int_add(lv_t, sp_use(sp_String_cstr(self->iv_buf)));
  }
  puts("{ sp_str_concat(sp_String_cstr(x), y) }");
  while (0) { sp_box_int(1); }
  return lv_t;
}
static sp_RbVal sp_pd_0(sp_RbVal _t0) { return sp_box_int(0); }
EOF
  cat > new.c <<'EOF'
static sp_RbVal sp_pd_0(sp_RbVal _t0);
static sp_int sp_use(const char * lv_s) {
  const char *_c = sp_str_concat(sp_String_cstr(sp_holder_buf), "");
  return sp_str_getbyte(lv_s, 0);
}
static sp_int sp_run(sp_Holder *self, sp_int lv_n) {
  sp_int lv_t = 0;
  for (sp_int _t1 = 0; _t1 < lv_n; _t1++) {
    lv_t = sp_int_add(lv_t, sp_use(sp_str_concat(sp_String_cstr(self->iv_buf), "")));
    const char *_k = sp_str_b(lv_s); SP_GC_ROOT(_k);
  }
  for (sp_int _t2 = 0; _t2 < 3; _t2++) sp_keep(sp_str_dup(lv_s));
  sp_RbVal _r = sp_pd_0(sp_box_int(lv_t));
  puts("{ sp_str_concat(sp_String_cstr(x), y) }");
  while (0) { sp_box_int(1); }
  return sp_str_concat(sp_String_cstr(self->iv_buf), "") ? lv_t : 0;
}
static sp_RbVal sp_pd_0(sp_RbVal _t0) { return sp_box_int(0); }
EOF
  bash "$ROOT/tools/c_costs.sh" new.c
  bash "$ROOT/tools/c_costs.sh" ref.c new.c prog.rb
  printf 'one.rb ref.c new.c\ntwo.rb ref.c ref.c\nthree.rb ref.c missing.c\n' > list
  bash "$ROOT/tools/c_costs.sh" --list list | head -1
  ;;
costs-live)
  # a program with a main: a runtime helper nothing calls, boxing in a
  # loop of its own; a callback main only names, which counts; a function
  # calling itself and two calling each other, which run once per level of
  # the recursion, as a loop body does, and a leaf they call
  cat > live.c <<'EOF'
static sp_PolyArray *sp_class_ancestors(sp_Class c) {
  sp_PolyArray *a = sp_PolyArray_new();
  for (sp_Class cur = c; cur.cls_id; cur = sp_class_super(cur)) sp_PolyArray_push(a, sp_box_class(cur));
  return a;
}
static void sp_K__gc_scan(void *p) { sp_keep(sp_box_int(1)); }
static sp_int sp_leaf(sp_int n) { return sp_poly_to_i(sp_box_int(n)); }
static sp_int sp_fact(sp_int n) { return n < 2 ? sp_leaf(1) : n * sp_fact(n - 1); }
static sp_int sp_odd(sp_int n);
static sp_int sp_even(sp_int n) { return n == 0 ? 1 : sp_odd(sp_poly_to_i(sp_box_int(n - 1))); }
static sp_int sp_odd(sp_int n) { return n == 0 ? 0 : sp_even(n - 1); }
int main(int argc, char **argv) {
  sp_K *k = SP_POOL_NEW(K, sp_K__gc_scan);
  sp_RbVal v = sp_box_int(sp_fact(5) + sp_even(4));
  return 0;
}
EOF
  bash "$ROOT/tools/c_costs.sh" live.c
  ;;
alloc)
  # grew.rb allocates past the threshold, same.rb does not, args.rb gets
  # the two words of its .args, quiet.rb prints differently, clock.rb
  # reads the clock, exits.rb exits 1 only on the new side, raises.rb exits
  # 1 on both, empty.rb allocates only on the new side, and d/e.rb and
  # d_e.rb differ only in a slash
  mkdir d
  for p in grew same args quiet clock exits raises empty d/e d_e; do
    printf 'p 1\n' > $p.rb
    for side in ref new; do printf 'out\n' > $p.rb.$side.out
      printf 'alloc;String 10\nalloc;Holder 2\n# bytes String 1000\n# bytes Holder 32\n' > $p.rb.$side.alloc; done
  done
  printf 'alloc;String 2010\nalloc;Holder 2\n# bytes String 2001000\n# bytes Holder 32\n' > grew.rb.new.alloc
  printf 'alloc;String 11\nalloc;Holder 2\n# bytes String 1100\n# bytes Holder 32\n' > same.rb.new.alloc
  printf '1000000 200\n' > args.rb.args
  printf 'other\n' > quiet.rb.new.out
  printf 'p Time.now\n' > clock.rb
  printf '1\n' > exits.rb.new.rc; printf '1\n' > raises.rb.ref.rc; printf '1\n' > raises.rb.new.rc
  : > empty.rb.ref.alloc
  printf 'alloc;String 5000\nalloc;Holder 2\n# bytes String 500000\n# bytes Holder 32\n' > d_e.rb.new.alloc
  bash "$ROOT/tools/alloc_diff.sh" ./ref ./new grew.rb same.rb args.rb quiet.rb clock.rb exits.rb raises.rb empty.rb d/e.rb d_e.rb
  # a job count xargs refuses is an infrastructure error
  ALLOC_DIFF_JOBS=x bash "$ROOT/tools/alloc_diff.sh" ./ref ./new same.rb 2> /dev/null || echo "alloc_diff exit $?"
  ;;
esac
