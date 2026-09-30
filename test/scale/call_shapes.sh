#!/bin/sh
# call_shapes.sh N: a Ruby program of N units of the call shapes that the
# argument binder and the block-parameter typing plan site by site, for `make
# scale-test`, which compiles it to C at N and 4N and compares the two work
# counts. Every unit repeats the same method and local names, and holds:
#   - a buffer method each unit's two classes define (`render_into`), called
#     on self from the base and on the subclass, while a POLY seed makes its
#     io a shared handle (#6065, #6135); one POLY receiver at the end reaches
#     all 2N of them;
#   - sixteen calls lending four String locals to a parameter that appends,
#     on a name every unit defines: the sites a per-site walk multiplies;
#   - poly dispatch with a String among arguments that run (#6183), on a name
#     only the unit's two classes define (a dispatch lists every class that
#     defines the name, so one name shared at a site in every unit would make
#     the emitted C itself grow with N squared);
#   - a String local that a later argument rebinds, `h(.., d, (d = ..; 1))`;
#   - optionals, a splat, keywords and a keyword rest through one plan, with
#     arguments that run and rebind what a later one spreads;
#   - yield(*row) into block parameters, with short rows and Float rows;
#   - nullable Integer locals read in a case, a type test and a Hash key;
#   - blocks a method stores, keeps through a `||`, or hands on;
#   - index writes, splices, inserts and fills past the end.
# The program and its C grow linearly in N, and CRuby runs it: a pass that
# rescans the program per call site or per argument grows with N squared.
N=${1:-10}
awk -v N="$N" 'BEGIN {
  print "LONG = \".\" * 20"
  print "module Helper"
  print "  def self.open_into(io) = (io << \"<\" << LONG; nil)"
  print "end"
  print "Helper.open_into([]) if ARGV.size > 5   # a second caller makes io POLY"
  print "$n = 0"
  print "def touch = ($n += 1)"
  print "class Keeper"
  print "  def initialize = @cb = nil"
  print "  def keep(&b) = (@cb = b; self)"
  print "  def keep_or(&b) = (@cb = b || @cb; self)"
  print "  def pass(&b) = keep(&b)"
  print "  def fire(x) = @cb.call(x)"
  print "end"
  for (i = 0; i < N; i++) {
    printf "class Base%d\n", i
    print  "  def render_into(io, n) = (io << \"b#{n}\"; nil)"
    printf "  def pf%d(k, io, j) = (io << \"q#{k}#{j}\"; nil)\n", i
    print  "  def render = (io = String.new; render_into(io, 1); io)"
    print  "end"
    printf "class View%d < Base%d\n", i, i
    print  "  def render_into(io, n) = (Helper.open_into(io); io << \"v#{n}\"; nil)"
    printf "  def pf%d(k, io, j) = (Helper.open_into(io); io << \"l#{k}#{j}\"; nil)\n", i
    print  "end"
    printf "class Unit%d\n", i
    print  "  def plain_into(io) = (io << \"p\"; nil)"
    print  "  def h(k0, io, k) = (Helper.open_into(io); io << \"h#{k0}#{k}\"; nil)"
    print  "  def fill(io, n) = (io << \"f#{n}\"; nil)"
    print  "  def lent"
    print  "    a = String.new; fill(a, 1); fill(a, 2); fill(a, 3); fill(a, 4)"
    print  "    b = String.new; fill(b, 5); fill(b, 6); fill(b, 7); fill(b, 8)"
    print  "    c = +\"c\"; fill(c, 9); fill(c, 10); fill(c, 11); fill(c, 12)"
    print  "    e = +\"e\"; fill(e, 13); fill(e, 14); fill(e, 15); fill(e, 16)"
    print  "    a.size + b.size + c.size + e.size"
    print  "  end"
    print  "  def rebound"
    print  "    buf = +\"\""
    print  "    d = String.new"
    print  "    plain_into(d)"
    print  "    keep = d"
    print  "    h((buf << \"ab\"; buf.upcase!; buf.size), d, (d = String.new; 1))"
    print  "    keep.size + d.size + buf.size"
    print  "  end"
    print  "  def poly"
    print  "    t = 0"
    printf "    [Base%d.new, View%d.new].each do |v|\n", i, i
    print  "      io = String.new"
    printf "      v.pf%d(touch, io, touch)\n", i
    print  "      io2 = String.new; kept = io2"
    printf "      v.pf%d(1, io2, (io2 = String.new; 2))\n", i
    print  "      t += io.size + kept.size + io2.size + v.render.size"
    print  "    end"
    print  "    t"
    print  "  end"
    print  "  def plan(a, b = 2, *r, k: 1, **o) = a + b + r.size + k + o.size"
    print  "  def plans"
    print  "    xs = [1, 2, 3]"
    print  "    kw = { k: 4, z: 5 }"
    print  "    t = plan(*xs, k: 3) + plan(1, **kw) + plan(*xs, **kw) + plan(7)"
    print  "    t += plan(touch, (xs = [9, 8]; 2), *xs, k: touch)"
    print  "    t += plan(*xs, k: (xs = [1]; 3), **kw)"
    print  "    t += plan(touch, touch, *xs, k: touch, z: touch)"
    print  "    t += plan((xs = [4, 5]; 1), *xs, **kw, y: touch)"
    print  "    t + plan(xs.size, touch, (kw = { k: 1 }; 2), **kw)"
    print  "  end"
    print  "  def rows(t) = t.each { |row| yield(*row) }"
    print  "  def spread(r) = yield(*r)"
    print  "  def blocks"
    print  "    s = 0"
    print  "    rows([[1, 2, 3], [4, 5], [6]]) { |a, b, c| s += a + (b || 0) + (c ? c : 0) }"
    print  "    f = 0.0"
    print  "    rows([[1.5], [2.5, 0.5]]) { |x, y| f += x + (y || 0.25) }"
    print  "    spread([7, nil]) { |a, b| s += b.nil? ? a : b }"
    print  "    s + f.to_i"
    print  "  end"
    print  "  def nullable(n)"
    print  "    best = nil"
    print  "    n.times { |j| best = j if best.nil? || j > best }"
    print  "    v = n > 2 ? n : nil"
    print  "    h = { nil => 1, 3 => 2 }"
    print  "    c = case v when nil then 10 when Integer then 20 end"
    print  "    (best || -1) + c + h[v].to_i + (Integer === v ? 1 : 0) + v.to_i"
    print  "  end"
    print  "  def escaping"
    print  "    k = Keeper.new.keep { |x| x * 2 }"
    print  "    a = k.fire(3)"
    print  "    k.keep_or { |x| x + 1 }"
    print  "    b = k.fire(4)"
    print  "    k.pass { |x| x.to_s.size }"
    print  "    a + b + k.fire(12345)"
    print  "  end"
    print  "  def gaps(n)"
    print  "    a = [1, 2]"
    print  "    i = a.size + n"
    print  "    a[i] = 5"
    print  "    a[i + 3, 0] = [7]"
    print  "    a.insert(i + 6, 8)"
    print  "    a.fill(9, i + 9, 1)"
    print  "    a.size + a.compact.sum"
    print  "  end"
    printf "  def run = lent + rebound + poly + plans + blocks + nullable(%d) + escaping + gaps(%d)\n", i % 5, i % 3
    print  "end"
  }
  print "acc = 0"
  for (i = 0; i < N; i++) {
    printf "acc += Unit%d.new.run\n", i
    printf "io = String.new; View%d.new.render_into(io, %d); acc += io.size\n", i, i
  }
  print "views = []"
  for (i = 0; i < N; i++) printf "views << Base%d.new << View%d.new\n", i, i
  print "views.each { |v| io = String.new; v.render_into(io, touch); acc += io.size }"
  print "p acc"
  print "p $n"
}'
