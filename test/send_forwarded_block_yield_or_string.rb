class C
  def impl = block_given? ? yield : "none"
  def twice(x) = block_given? ? yield(x) * 2 : [x]
end

def fwd(o, m, &) = o.send(m, &)
p fwd(C.new, :impl)
p fwd(C.new, :impl) { 7 }

def fwd_named(o, m, &blk) = o.send(m, &blk)
p fwd_named(C.new, :impl) { 8 }
p fwd_named(C.new, :impl)

def direct(o, &) = o.impl(&)
p direct(C.new)
p direct(C.new) { 9 }

def dots(o, ...) = o.impl(...)
p dots(C.new) { 10 }
p dots(C.new)

def outer(o, &b) = direct(o, &b)
p outer(C.new)
p outer(C.new) { 11 }

def never(o, &) = o.impl(&)
p never(C.new)
p never(C.new)

def always(o, &) = o.impl(&)
p always(C.new) { 12 }
p always(C.new) { 13 }

def tw(o, &) = o.twice(4, &)
p tw(C.new)
p tw(C.new) { |x| x + 1 }
