def a
  log = []
  r = ->(x) { log << :recv; x }
  r.(1).step(by: begin log << :by; 2 end, to: begin log << :to; 5 end) { |i| log << i }
  log
end
p a
def b
  log = []
  r = ->(x) { log << :recv; x }
  r.(1).step(to: begin log << :to; 5 end, by: begin log << :by; 2 end) { |i| log << i }
  log
end
p b
def c
  log = []
  r = ->(x) { log << :recv; x }
  e = r.(1).step(by: (log << :by; 2), to: (log << :to; 5)).to_a
  [log, e]
end
p c
def d
  log = []
  1.step(by: begin log << :by; 2 end, to: begin log << :to; 5 end) { |i| log << i }
  log
end
p d
log = []
x = [1, 2].map { |s| s.step(by: begin log << :by; 1 end, to: begin log << :to; 3 end).to_a }
p x, log
p 1.step(by: 2, to: 9).to_a
[["x", 9], [:a, 9]].each do |pair|
  t = pair[0]
  begin
    1.step(t, 2).to_a
  rescue ArgumentError => e
    p e.message
  end
end
