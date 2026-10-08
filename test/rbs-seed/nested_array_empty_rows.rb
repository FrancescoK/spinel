# An `Array[Array[Integer]]` / `Array[Array[Float]]` seed supplies the row
# kind when the program's own rows are silent: every row here is an empty
# `[]` (a generator block, a literal, a push, a `[]=` store, and `@c = []`
# grown later), which carries no element kind of its own. Without the seed
# these stay boxed poly arrays; with it each table is an sp_PtrArray of typed
# rows and the empty literals are built as rows of that kind (#4484).
# spinel: rbs-seed-check
class EmptyRowTables
  def initialize(n)
    @a = Array.new(n) { [] }
    @b = [[], []]
    @c = []
    @d = Array.new(n) { [] }
  end
  def grow
    @c << []
    @c.push([])
    @d[0] = []
    k = 0
    while k < @a.length
      @a[k] << k * 1.5
      @b[k % 2] << k
      @c[k % 2] << k * 2
      @d[k] << k * 0.25
      k += 1
    end
  end
  def sums
    s = [0.0, 0, 0, 0.0]
    k = 0
    while k < @a.length
      r = @a[k]; j = 0
      while j < r.length; s[0] += r[j]; j += 1; end
      k += 1
    end
    k = 0
    while k < @b.length
      r = @b[k]; j = 0
      while j < r.length; s[1] += r[j]; j += 1; end
      k += 1
    end
    k = 0
    while k < @c.length
      r = @c[k]; j = 0
      while j < r.length; s[2] += r[j]; j += 1; end
      k += 1
    end
    k = 0
    while k < @d.length
      r = @d[k]; j = 0
      while j < r.length; s[3] += r[j]; j += 1; end
      k += 1
    end
    s
  end
end
t = EmptyRowTables.new(4)
t.grow
p t.sums
p t.sums.length
