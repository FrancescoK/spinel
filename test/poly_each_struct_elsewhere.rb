# A block over a boxed Array stays inline beside a Struct's each
# A boxed receiver's `each { }` (and map, select, ...) went through a proc
# and a run-time dispatch as soon as any class of the program had an `each`
# that yields, a Struct among them, though the receiver's class fact kept
# that class out and the dispatch had no arm for it.

Point = Struct.new(:x, :y)
pt = Point.new(1, 2)
p pt.x + pt.y

# nested ops: Integers and Arrays, read from a boxed parameter
def run(ops, acc)
  ops.each do |op|
    if op.is_a?(Array)
      run(op, acc)
    else
      acc[0] += op
    end
  end
  acc[0]
end

def parse(s, i = [0])
  ops = []
  while i[0] < s.size
    c = s[i[0]]
    i[0] += 1
    case c
    when "(" then ops << parse(s, i)
    when ")" then return ops
    else ops << c.to_i
    end
  end
  ops
end

def count(ops)
  n = 0
  ops.each { |op| n += op.is_a?(Array) ? count(op) : 1 }
  n
end

prog = parse("12(34(5)6)7")
p run(prog, [0]), count(prog)
p prog.map { |o| o.is_a?(Array) ? o.size : o }
p prog.select { |o| o.is_a?(Integer) }

