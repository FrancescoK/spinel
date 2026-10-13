# A multiple assignment from an untyped value: the rest target and the
# targets after it take the elements the run time hands them, so a method
# answering them is typed by them too.
class Cop
  def split(_) = [:a, :b]
end

def department_of(name)
  *dept, _ = name.split('/')
  return nil if dept.empty?
  dept.join('/')
end
p department_of("Style/Foo")
p department_of("Foo")
p department_of(Cop.new)

def last_of(v)
  *_, last = v
  last
end
p last_of([1, 2, 3])
p last_of("x")
p last_of({a: 1})

def middle(v)
  first, *mid, last = v
  [first, mid, last]
end
p middle([1, 2, 3, 4])
p middle(:s)
p middle(nil)

def head_size(v)
  *h, _ = v
  if h.size > 1
    h.first
  else
    h.size
  end
end
p head_size([1, 2, 3])
p head_size(["a"])
p head_size(4)

def rests(vs)
  out = []
  vs.each do |v|
    *r, t = v
    out << [r, t]
  end
  out
end
p rests([[1, 2], "s", nil, [:a, :b, :c]])
