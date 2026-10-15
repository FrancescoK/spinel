# A `tap` given a literal block, called on a call that answers its receiver
# (`@s.itself.tap { }`, `gs.itself.tap { }`) and boxed (a conditional's arm
# stored into a variable, a `case` arm, an `||` or `&&` operand of a method's
# tail), answers the receiver's String itself under --share-strings (#6765).
# The receiver's handle was held in a temp declared inside the value
# expression, after the statements of the block that read it had been placed
# ahead of the statement, so the C did not build. The handle is now held
# ahead of the block with them. `then` and a block that appends to its
# parameter are the same boxes.
def pass(x) = x
class App
  def initialize(s) = (@s = s)
  def gs = @s
  def arm_tap(v)
    x = v ? @s.itself.tap {} : 1
    x << "!"
    x
  end
  def arm_tap_blk(v)
    x = v ? @s.itself.tap { |z| z << "-" } : 1
    x << "!"
    x
  end
  def arm_then(v)
    x = v ? @s.itself.then { |z| z } : 1
    x << "!"
    x
  end
  def arm_case(v)
    x = case v when 1 then @s.itself.tap {} else 2 end
    x << "!"
    x
  end
  def arm_if(v)
    x = if v then gs.itself.tap {} else 2 end
    x << "!"
    x
  end
  def or_tap(v) = @s.itself.tap {} || v
  def or_tap_blk(v) = @s.itself.tap { |z| z << "+" } || v
  def or_then(v) = @s.itself.then { |z| z } || v
  def and_tap(v) = v && @s.itself.tap {}
end
[[:arm_tap, true], [:arm_tap_blk, true], [:arm_then, true], [:arm_case, 1], [:arm_if, true], [:or_tap, 1], [:or_tap_blk, 1], [:or_then, 1], [:and_tap, 1]].each do |m, v|
  a = +"abc"
  y = pass(App.new(a).send(m, v))
  p [m, a, y.equal?(a)]
end
