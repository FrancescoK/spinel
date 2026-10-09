# spinel: gc-stress
# spinel: share
# A modifier rescue's exception frame belongs to its expression: a return,
# break or next out of the expression pops it (left behind, a hundred of
# them ran out of frames), and an ensure inside it hands its exception to
# the rescue rather than to an enclosing ensure.
def ret
  ([1].each { |v| return v }) rescue nil
  2
end

def ret_value
  x = ([1].each { |v| return v + 1 } rescue nil)
  x
end

def brk
  i = 0
  while true
    (i += 1; break if i > 0) rescue nil
  end
  i
end

def nxt
  s = 0
  [1, 2].each { |v| (next if v == 1; s += v) rescue nil }
  s
end

t = 0
100.times { t += ret }
100.times { t += ret_value }
100.times { t += brk }
100.times { t += nxt }
p t

begin
  begin
    raise "x"
  ensure
    puts "inner ensure ran"
  end rescue puts("rescued")
  v = (begin; raise "y"; ensure; puts "inner ensure ran"; end rescue :rescued)
  p v
ensure
  puts "outer ensure ran"
end

# A return from under one evaluates its value while the rescue is live, in
# a void method and in a nil-valued lambda.
def void_return(n)
  begin
    return puts(1 / n)
  end rescue puts("rescued")
  nil
end
void_return(0)

f = -> do
  [1].each { return nil } rescue nil
  nil
end
p f.call
g = -> do
  x = ([1].each { return nil } rescue nil)
  x
end
p g.call
