# spinel: gc-stress
p select([], [], [], 0)
r, w = IO.pipe
p select([r], nil, nil, 0)
w.write("x")
w.flush
ready = select([r])
p [ready[0][0].equal?(r), ready[1], ready[2]]
ready = Kernel.select(nil, [w], nil, 0)
p [ready[0], ready[1][0].equal?(w), ready[2]]
p ::Kernel.select([], [], [], 0)
begin
  select(r, nil, nil, 0)
rescue TypeError => e
  p e.message
end
r.close
w.close
