# A String Range's endpoint, as the value of an inlined yield (the block's
# last value or a `next`) or of a Fiber or Thread body, is the endpoint's own
# String. Under --share-strings the value was handed on the handle route's
# answer, which wraps a new handle around an endpoint the Range does not keep
# as one (nothing here changes a String in place, so a Range holds its
# endpoints as they are), and equal? said it was another object.
def m = yield
a = +"a"; b = +"c"; r = a..b
p m { next r.end }.equal?(b)
p m { next r.begin }.equal?(a)
p m { next r.end if true; 1 }.equal?(b)
p m { r.end }.equal?(b)
p m { r.begin }.equal?(a)
x = m { next r.end }
p x.equal?(b)
y = m { r.end }
p y.equal?(b), y
f = Fiber.new { next r.end }
p f.resume.equal?(b)
f = Fiber.new { r.end }
p f.resume.equal?(b)
p Thread.new { next r.begin }.value.equal?(a)
p Thread.new { r.begin }.value.equal?(a)
p r.end.equal?(b), r.begin.equal?(a)
# ...and through the arms of a conditional (the endpoint on an arm of a ?:, if,
# unless, case, `&&`, `||`, parentheses or begin), in a yield, a Fiber and a
# Thread
c = ARGV.size == 0
p m { c ? r.end : "z" }.equal?(b)
p m { if c then r.end else "z" end }.equal?(b)
p m { unless c then "z" else r.end end }.equal?(b)
p m { case 1 when 1 then r.end else "z" end }.equal?(b)
p m { c && r.end }.equal?(b)
p m { nil || r.end }.equal?(b)
p m { (r.end) }.equal?(b)
p m { begin; r.end; end }.equal?(b)
p m { c ? (next r.end) : "z" }.equal?(b)
p m { next (c ? r.end : "z") }.equal?(b)
p Fiber.new { c ? r.end : "z" }.resume.equal?(b)
p Fiber.new { next(c ? r.end : "z") }.resume.equal?(b)
p Fiber.new { c ? (next r.end) : "z" }.resume.equal?(b)
p Thread.new { c ? r.end : "z" }.value.equal?(b)
p Thread.new { next(c ? r.end : "z") }.value.equal?(b)
p Thread.new { case 1 when 1 then r.end else "z" end }.value.equal?(b)
# ...through a begin with a rescue, an else or an ensure, and a rescue modifier
x = 0
p m { begin; r.end; rescue; "z"; end }.equal?(b)
p m { begin; raise "e"; rescue; r.end; end }.equal?(b)
p m { begin; r.end; ensure; x += 1; end }.equal?(b)
p m { begin; r.begin; rescue; "z"; else; r.end; ensure; x += 1; end }.equal?(b)
p m { r.end rescue "z" }.equal?(b)
p Fiber.new { begin; r.end; rescue; "z"; end }.resume.equal?(b)
p Thread.new { begin; raise "e"; rescue; r.end; ensure; x += 1; end }.value.equal?(b)
p m { next(begin; r.end; rescue; "z"; end) }.equal?(b)
# ...and through nested yields
p m { m { r.end } }.equal?(b)
p m { m { next r.end } }.equal?(b)
p Fiber.new { m { r.end } }.resume.equal?(b)
p Thread.new { m { r.end } }.value.equal?(b)
