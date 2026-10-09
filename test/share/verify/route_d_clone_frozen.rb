s = +"a"; s << "b"; s.freeze; t = s.clone; p t.frozen?, t.equal?(s)
u = s.clone(freeze: false); u << "!"; p u, s
