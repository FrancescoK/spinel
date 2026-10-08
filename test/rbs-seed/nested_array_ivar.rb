# `Array[Array[Integer]]` / `Array[Array[Float]]` as ivar seeds.
#
# They are element EVIDENCE for the post-fixpoint narrowing pass, not type
# pins. Pinning the type would be worse than saying nothing: the tags map to no
# scalar kind, so the seed would pin the ivar to a boxed poly array, and a
# pinned ivar is skipped by the very pass that produces the unboxed table -- the
# accurate signature made the program slower, silently. (The rows here carry
# their own kind; nested_array_empty_rows.rb is the case the seed decides.)
#
# With the seed applied both tables must still narrow (sp_PtrArray of
# sp_IntArray* / sp_FloatArray*) and the program must answer what CRuby answers.
# spinel: rbs-seed-check
class Tables
  attr_reader :ints, :flts
  def initialize(n)
    @ints = Array.new(n) { Array.new(0, 0) }
    @flts = Array.new(n) { Array.new(0, 0.0) }
  end
  def fill
    k = 0
    while k < @ints.length
      ir = @ints[k]
      fr = @flts[k]
      j = 0
      while j < 3
        ir << k * 10 + j
        fr << k * 10.0 + j * 0.5
        j += 1
      end
      k += 1
    end
  end
  def total_i
    s = 0
    k = 0
    while k < @ints.length
      r = @ints[k]
      j = 0
      while j < r.length
        s += r[j]
        j += 1
      end
      k += 1
    end
    s
  end
  def total_f
    s = 0.0
    k = 0
    while k < @flts.length
      r = @flts[k]
      j = 0
      while j < r.length
        s += r[j]
        j += 1
      end
      k += 1
    end
    s
  end
end

t = Tables.new(3)
t.fill
p t.total_i
p t.total_f
p t.ints[1]
p t.flts[2][0]
p t.ints.length
