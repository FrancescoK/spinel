def a
  log = []
  r = ->(x) { log << :recv; x }
  r.(1).step(5, begin log << :lim; 2 end) { |i| log << i }
  log
end
p a
def b
  log = []
  r = ->(x) { log << :recv; x }
  r.(1).step(nil, begin log << :st; 2 end) { |i| log << i; break if i > 4 }
  log
end
p b
def c
  log = []
  r = ->(x) { log << :recv; x }
  r.(1.0).step(begin log << :lim; 2.0 end, 0.5) { |i| log << i }
  log
end
p c
def d(n)
  log = []
  n&.step(3) { |i| log << i }
  log
end
p d(nil), d(2)
