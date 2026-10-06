# A typed array that may be nil, read through a field in a loop whose array
# headers are cached (emit_while), raises NoMethodError when it is nil and
# reads from the cache when it is not. The nil test bound the receiver into
# a temp, so `ctx.resid[...]` dropped out of the cache and the loop reread
# the array at every pass. A nil array's cached length is 0, so a non-nil
# empty array takes the same test and must not raise NoMethodError. A read
# tests the receiver in its out-of-range branch, and `size` ahead of the
# call. A nil index raises TypeError, after a nil receiver's NoMethodError.
class Ctx
  attr_accessor :resid

  def initialize
    @resid = nil
  end
end

def show(tag)
  r = yield
  puts "#{tag} #{r.inspect}"
rescue => e
  puts "#{tag} #{e.class}: #{e.message}"
end

def field_scatter(ctx, idx, bins, n, z)
  j = 0
  while j < n
    z[bins[j]] += ctx.resid[idx[j]]
    j += 1
  end
  z
end

def field_count(ctx, idx, n)
  c = 0
  j = 0
  while j < n
    c += 1 if ctx.resid[idx[j]].nil?
    j += 1
  end
  c
end

def field_size(ctx, n)
  t = 0
  j = 0
  while j < n
    t += ctx.resid.size
    j += 1
  end
  t
end

def field_at(ctx, s, n)
  k = s.index("b")
  c = 0
  j = 0
  while j < n
    c += 1 if ctx.resid[k].nil?
    j += 1
  end
  c
end

ctx = Ctx.new
idx = [2, 0, 1, 2]
bins = [0, 1, 0, 1]
show("field nil") { field_scatter(ctx, idx, bins, 4, [0.0, 0.0]) }
show("field nil, no pass") { field_scatter(ctx, idx, bins, 0, [0.0, 0.0]) }
ctx.resid = [0.5, 1.25, 2.0]
show("field") { field_scatter(ctx, idx, bins, 4, [0.0, 0.0]) }
show("field count") { field_count(ctx, idx, 4) }
ctx.resid = Array.new(0, 0.0)
show("field empty") { field_count(ctx, idx, 4) }
ctx.resid = nil
show("field nil count") { field_count(ctx, idx, 4) }
show("field nil size") { field_size(ctx, 2) }
ctx.resid = Array.new(0, 0.0)
show("field empty size") { field_size(ctx, 2) }
ctx.resid = nil
show("field nil, nil index") { field_at(ctx, "xyz", 2) }
ctx.resid = [0.5, 1.5]
show("field, nil index") { field_at(ctx, "xyz", 2) }
show("field, index") { field_at(ctx, "abc", 2) }
