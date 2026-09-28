# A block given to an implicit-self call that a subclass override yields to
# becomes a real proc on the runtime-class dispatch, so what it captures -- a
# plain local, a written counter, the method's own &blk -- lives in cells even
# though the method resolved in the base class ignores the block (#5381, the
# shape of Phlex's view_template).
class Base
  def tmpl
    p :base
  end
  def run(v)
    tmpl { |x| p [v, x] }
    nil
  end
end
class V < Base
  def tmpl
    yield(1)
  end
end
V.new.run(:x)
Base.new.run(:y)

class Base2
  def view_template
    p :base_template
  end

  def call(n, &blk)
    count = 0
    view_template do |*args|
      count += 1
      blk ? blk.call(n, *args) : p([n, args])
    end
    count
  end
end

class Page2 < Base2
  def view_template
    yield(1, 2)
    yield
  end
end

class Plain2 < Base2; end

p Page2.new.call(:a) { |n, *r| p [:blk, n, r] }
p Page2.new.call(:b)
p Plain2.new.call(:c)
