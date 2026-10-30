# A class no reached code builds has no constructor that runs its yielding
# initialize: the proc-form clone of it is not written, and the
# constructor does not name it. A `new` on a Class value is what makes the
# clone (#10592).
# absent: sp_Pool_initialize_pf
class Pool
  def initialize(size)
    @free = []
    i = 0
    while i < size
      @free.push(yield)
      i += 1
    end
  end

  def self.label
    "pool"
  end
end

class Item
  def initialize(n)
    @n = n
  end

  def n
    @n
  end
end

klass = ARGV.size > 5 ? String : Item
p Pool.label
p klass.new(1).n
