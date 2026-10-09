$log = []
def ri(x) = ($log << :recv; x)
def ra(x) = ($log << :recv; x)
def rs(x) = ($log << :recv; x)
def rh(x) = ($log << :recv; x)
def stp(x) = ($log << :step; x)
def show(label, r)
  p [label, r, $log.dup]
  $log.clear
end

r1 = ri(1).step(nil, begin; $log << :begin; stp(2); end).first(3)
show :endless_step, r1
r2 = ri(1).step(10, begin; $log << :begin; stp(3); end).to_a
show :bounded_step, r2
r3 = ri(1) + begin; $log << :begin; stp(2); end
show :plus, r3
r4 = ra([1]).push(begin; $log << :begin; stp(2); end)
show :push, r4
r5 = rs("a").center(begin; $log << :begin; stp(5); end)
show :center, r5
r6 = rh({a: 1}).fetch(:a, begin; $log << :begin; stp(2); end)
show :fetch, r6
r7 = ri(1).upto(begin; $log << :begin; stp(3); end).to_a
show :upto, r7
r8 = ra([1]).push(begin; $log << :begin; stp(2); rescue; 0; end)
show :rescue_arg, r8
r9 = ra([1]).push(stp(5), begin; $log << :begin; 6; end)
show :earlier_arg, r9

a = []
ri(1).step(stp(5), stp(2)) { |v| a << v }
show :block_step, a

n = [nil, [1]][0]
r10 = n&.push(begin; $log << :begin; 2; end)
show :safe_nav_nil, r10
