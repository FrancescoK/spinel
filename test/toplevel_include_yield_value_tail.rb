# The value of a bare call to a yielding method of a module included at the
# top level. The call is spliced inline, like any yielding method, but two
# places did not resolve it the way the inliner does:
# - the analyzer never matched the call's block to the method's yield, so a
#   used value (`n = twice { 2 }`) typed nil;
# - a block whose tail is such a call took the statement form, so the block
#   answered void and `unless yield` did not compile.

class DbErr < StandardError; end

module T
  module_function

  def check(label)
    raise "FAIL: #{label}" unless yield
    puts "ok #{label}"
  end

  def raises?
    yield
    false
  rescue DbErr
    true
  end

  def twice
    yield + yield
  end
end

include T

# a block tail that is such a call, whose inner block always raises
check("raising block") { raises? { raise DbErr, "boom" } }

# the inner block returns normally
check("quiet block") { !raises? { 1 } }

# through the module, which already worked
check("module form") { T.raises? { raise DbErr, "boom" } }

# the call's value, read by an assignment, a method's tail and a block
n = twice { 2 }
p n

def four_of(x) = twice { x + x }
p four_of(1)

p [1, 2].map { |x| twice { x + 1 } }
p [3].map { |x| twice { x } }.first
