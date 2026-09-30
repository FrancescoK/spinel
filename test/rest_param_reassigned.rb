# A `*rest` parameter the body assigns to something other than an Array:
# the method took an sp_RbVal while callers passed the packed Array, and the
# C did not build (#6227). The background-job `perform(*args)` shape.
class Job
  def perform(*args)
    args = args.first
    p args
  end

  def perform_kw(*args)
    args = args.first
    p args[:id]
  end

  def grow(*args)
    args += [:tail]
    p args
  end

  def keep(*args)
    args << :more
    p args.size
  end

  def later(*args)
    n = args.size
    args = args.map(&:to_s)
    [n, args]
  end

  def in_block(*args)
    [1].each { args = args.reverse }
    args
  end
end

j = Job.new
j.perform(7)
j.perform("a", "b")
j.perform
j.perform_kw(id: 7)
j.grow(1, 2)
j.keep(1)
p j.later(1, :b)
p j.in_block(1, 2, 3)
