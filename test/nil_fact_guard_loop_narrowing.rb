# A read of a local under a guard that proves it is not nil stays guarded
# when the region writes the local only after the read: the list walk
# `while cur != nil; ...; cur = cur.nxt; end` and its `until cur.nil?` twin
# test the receiver nowhere (#7444). A read after a conditional write, or
# one a block inside the region runs again, is still a call on a value that
# may be nil, and raises NoMethodError as CRuby does when it is.
class Cell
  attr_accessor :nxt, :v
  def initialize(v, nxt) = (@v = v; @nxt = nxt)
end

def sum(head)
  cur = head
  s = 0
  while cur != nil
    s += cur.v
    cur = cur.nxt
  end
  s
end

def last(head)
  cur = head
  prev = nil
  until cur.nil?
    prev = cur
    cur = cur.nxt
  end
  prev
end

def try
  yield
rescue NoMethodError => e
  puts e.message
end

list = Cell.new(1, Cell.new(2, Cell.new(3, nil)))
p sum(list), sum(nil)
p last(list).v, last(nil)

def second_value(head, skip)
  cur = head
  if cur
    cur = cur.nxt if skip
    return cur.v
  end
  0
end
p second_value(list, false), second_value(Cell.new(9, nil), false)
try { p second_value(Cell.new(9, nil), true) }

def every_third(head)
  cur = head
  out = []
  while cur
    3.times { out << cur.v; cur = cur.nxt }
  end
  out
end
try { p every_third(list) }
p every_third(Cell.new(1, Cell.new(2, Cell.new(3, Cell.new(4, Cell.new(5, Cell.new(6, nil)))))))
