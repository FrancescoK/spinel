def t(label)
  r = yield
  p [label, r]
rescue => e
  p [label, e.class, e.message]
end

class StepElsewhere
  def step(**kw) = kw
end

log = []
t(:step_kw) { 2.step(foo: 1) }
t(:step_kw_blk) { a = []; 2.step(foo: 1) { |i| a << i }; a }
t(:step_kw_to) { 2.step(to: 4, foo: 1).to_a }
t(:step_two) { 2.step(foo: 1, bar: 2) }
t(:step_pos) { 2.step(5, zap: 1) }
t(:step_order) { (log << :r; 2).step(by: (log << :b; 1), foo: (log << :f; 1)) }
p log
t(:step_float) { 1.5.step(foo: 1) }
t(:step_other_class) { StepElsewhere.new.step(count: 1, mode: 2) }
t(:step_ok) { 2.step(to: 6, by: 2).to_a }
x = [nil, 1][0]
t(:safe_nil) { x&.step(foo: 1) }
t(:safe_nonnil) { y = 2; y&.step(foo: 1) }
t(:upto_kw_blk) { a = []; 2.upto(foo: 1) { |i| a << i }; a }
t(:downto_kw_blk) { a = []; 2.downto(foo: 1) { |i| a << i }; a }
t(:times_kw) { 2.times(foo: 1) }
