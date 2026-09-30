# The left of a `||` whose value something keeps widens the block's
# parameters; the left of an `&&`, and a `||` a predicate reads, leave them
# where the method's own calls put them.
class OrKeptInfer
  def initialize(&blk)
    blk.call(1, 2)
    @cb = blk || ->(fa, fb) { [fa, fb] }
  end
  def fire(a, b) = @cb.call(a, b)
end
OrKeptInfer.new { |okaa, okbb| p [okaa, okbb] }.fire("or", :or)

def and_left_infer(&b)
  b.call(6)
  p((b && :set))
end
and_left_infer { |alaa| p alaa + 1 }

def or_pred_infer(&b)
  b.call(7)
  p :yes if b || true
end
or_pred_infer { |opaa| p opaa + 1 }

# the question moves up through each `||`, `&&` and pair of parentheses:
# `(b || true) && true` hands the block to the left of an `&&`, `false || b`
# to a predicate, and neither keeps it; `@cb = (x || b)` does
def or_nested_infer(&b)
  b.call(8)
  p :deep if (b || true) && true
end
or_nested_infer { |onaa| p onaa + 1 }

def or_right_infer(&b)
  b.call(9)
  p :right if false || b
end
or_right_infer { |oraa| p oraa + 1 }

class OrRightKeptInfer
  def initialize(&blk)
    blk.call(1)
    @cb = (nil || blk)
  end
  def fire(a) = @cb.call(a)
end
OrRightKeptInfer.new { |orkaa| p orkaa }.fire("kept")
