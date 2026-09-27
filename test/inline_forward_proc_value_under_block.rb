# Inside an inlined method that has a block of its own, `callee(&item)` with
# item a proc value runs that proc, not the enclosing method's block.
module M
  def m2
    yield
  end
  def outer
    list = [["a", proc { :inner }]]
    yield(:outer_arg)
    list.map { |(label, item)| M.m2(&item) }
  end
  module_function :m2, :outer
end
p M.outer { |x| p [:outer_block, x]; :outer_result }
