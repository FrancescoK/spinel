def pick(f) = f ? 1 : nil
def fpick(f) = f ? 1.5 : nil

log = []
x = pick(false)
x&.step(begin log << :to; 9 end, begin log << :by; 2 end) { |i| log << i }
x&.step(by: begin log << :by; 2 end, to: begin log << :to; 9 end) { |i| log << i }
r = x&.step(by: begin log << :by2; 2 end, to: begin log << :to2; 9 end)
e = x&.step(begin log << :e; 9 end, 2)
fx = fpick(false)
fx&.step(begin log << :fto; 9.0 end, begin log << :fby; 2.0 end) { |i| log << i }
b = [nil, 1][0]
b&.step(by: begin log << :bby; 2 end, to: begin log << :bto; 9 end) { |i| log << i }
p log, r, e

log = []
rcv = ->(v) { log << :recv; v }
y = pick(true)
rcv.(y)&.step(begin log << :to; 5 end, begin log << :by; 2 end) { |i| log << i }
rcv.(y)&.step(by: begin log << :by; 2 end, to: begin log << :to; 5 end) { |i| log << i }
s = rcv.(y)&.step(by: begin log << :by2; 2 end, to: begin log << :to2; 5 end)&.to_a
3&.step(by: begin log << :lby; 2 end, to: begin log << :lto; 7 end) { |i| log << i }
rcv.(fpick(true))&.step(by: begin log << :fby; 0.5 end, to: begin log << :fto; 2.5 end) { |i| log << i }
rcv.([nil, 1][1])&.step(by: begin log << :bby; 2 end, to: begin log << :bto; 5 end) { |i| log << i }
p log, s
