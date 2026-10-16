# --share-strings: a String Range's endpoint that is changed in place, as the
# value of an inlined yield (the block's last value or a `next`) or of a Fiber
# or Thread body, is the handle the Range keeps, so a change through the
# answer reaches the endpoint.
def m = yield
c = +"c"; d = +"d"; q = c..d
d << "x"
p m { next q.end }.equal?(d)
p m { q.end }.equal?(d)
p m { q.begin }.equal?(c)
p m { r2 = q; next r2.end }.equal?(d)
f = Fiber.new { next q.end }
p f.resume.equal?(d)
f = Fiber.new { q.end }
p f.resume.equal?(d)
p Thread.new { next q.end }.value.equal?(d)
p Thread.new { q.begin }.value.equal?(c)
y = m { next q.begin }
y << "!"
p [c, y, y.equal?(c)]
z = m { q.end }
z << "?"
p [d, z.equal?(d)]
f = Fiber.new { next q.begin }
f.resume << "?"
p [c, d]
# ...and through the arms of a conditional
c = ARGV.size == 0
p m { c ? q.end : "z" }.equal?(d)
p m { if c then q.end else "z" end }.equal?(d)
p m { unless c then "z" else q.end end }.equal?(d)
p m { case 1 when 1 then q.end else "z" end }.equal?(d)
p m { c && q.end }.equal?(d)
p m { nil || q.end }.equal?(d)
p m { (q.end) }.equal?(d)
p m { begin; q.end; end }.equal?(d)
p m { c ? (next q.end) : "z" }.equal?(d)
p m { next (c ? q.end : "z") }.equal?(d)
p Fiber.new { c ? q.end : "z" }.resume.equal?(d)
p Fiber.new { next(c ? q.end : "z") }.resume.equal?(d)
p Fiber.new { c ? (next q.end) : "z" }.resume.equal?(d)
p Thread.new { c ? q.end : "z" }.value.equal?(d)
p Thread.new { next(c ? q.end : "z") }.value.equal?(d)
p Thread.new { case 1 when 1 then q.end else "z" end }.value.equal?(d)
# ...through a begin with a rescue, an else or an ensure, and a rescue modifier
x = 0
p m { begin; q.end; rescue; "z"; end }.equal?(d)
p m { begin; raise "e"; rescue; q.end; end }.equal?(d)
p m { begin; q.end; ensure; x += 1; end }.equal?(d)
p m { begin; q.begin; rescue; "z"; else; q.end; ensure; x += 1; end }.equal?(d)
p m { q.end rescue "z" }.equal?(d)
p Fiber.new { begin; q.end; rescue; "z"; end }.resume.equal?(d)
p Thread.new { begin; raise "e"; rescue; q.end; ensure; x += 1; end }.value.equal?(d)
p m { next(begin; q.end; rescue; "z"; end) }.equal?(d)
# ...and through nested yields
p m { m { q.end } }.equal?(d)
p m { m { next q.end } }.equal?(d)
p Fiber.new { m { q.end } }.resume.equal?(d)
p Thread.new { m { q.end } }.value.equal?(d)
