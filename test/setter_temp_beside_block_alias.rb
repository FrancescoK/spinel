class Box
  def initialize = (@v = 0)
  def v=(x)
    @v = x * 2
  end
  def v = @v
end

def with_buf
  buf = +""
  yield buf
  buf
end

def run4(b)
  with_buf do |s|
    a1 = 1
    a2 = 2
    a3 = 3
    a4 = 4
    s << "x"
    w = (b.v = a1 + 4)
    s << w.to_s
  end
end

def run5(b)
  with_buf do |s|
    a1 = 1
    a2 = 2
    a3 = 3
    a4 = 4
    a5 = 5
    s << "x"
    w = (b.v = a1 + 5)
    s << w.to_s
  end
end

def run6(b)
  with_buf do |s|
    a1 = 1
    a2 = 2
    a3 = 3
    a4 = 4
    a5 = 5
    a6 = 6
    s << "x"
    w = (b.v = a1 + 6)
    s << w.to_s
  end
end

def run12(b)
  with_buf do |s|
    a1 = 1
    a2 = 2
    a3 = 3
    a4 = 4
    a5 = 5
    a6 = 6
    a7 = 7
    a8 = 8
    a9 = 9
    a10 = 10
    a11 = 11
    a12 = 12
    s << "x"
    w = (b.v = a1 + 12)
    s << w.to_s
  end
end

def run13(b)
  with_buf do |s|
    a1 = 1
    a2 = 2
    a3 = 3
    a4 = 4
    a5 = 5
    a6 = 6
    a7 = 7
    a8 = 8
    a9 = 9
    a10 = 10
    a11 = 11
    a12 = 12
    a13 = 13
    s << "x"
    w = (b.v = a1 + 13)
    s << w.to_s
  end
end

def run14(b)
  with_buf do |s|
    a1 = 1
    a2 = 2
    a3 = 3
    a4 = 4
    a5 = 5
    a6 = 6
    a7 = 7
    a8 = 8
    a9 = 9
    a10 = 10
    a11 = 11
    a12 = 12
    a13 = 13
    a14 = 14
    s << "x"
    w = (b.v = a1 + 14)
    s << w.to_s
  end
end

b = Box.new
p run4(b), b.v
b = Box.new
p run5(b), b.v
b = Box.new
p run6(b), b.v
b = Box.new
p run12(b), b.v
b = Box.new
p run13(b), b.v
b = Box.new
p run14(b), b.v
