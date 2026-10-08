# spinel: gc-minor
# A yielded conversion retains its String identity through typed and boxed
# block parameters, including an argument evaluated before another mutation.
def yield_text(value)
  yield value.to_s
end
value = +"seed"
box = [value, 1]
yield_text(box[0]) { |text| text << "!" }
p value, box[0]
yield_text(box[0], &->(text) { text << "?" })
p value, box[0]

def yield_order(value)
  yield value.to_s, (value << "x")
end
yield_order(box[0]) { |text, other| text << "y"; p text, other }
p value, box[0]

def yielded_fiber
  f = Fiber.new { Fiber.yield "k" + "2" }
  yield f.resume.to_s
end
result = +""
yielded_fiber { |text| result << text }
p result
$calls = 0
$values = [+"old", 1]
def source
  $calls += 1
  $values[0]
end
def yield_replaced_receiver
  yield source.to_s, ($values[0] = +"new")
end
old = $values[0]
yield_replaced_receiver { |text, other| text << "!"; p text, other }
p old, $values[0], $calls
