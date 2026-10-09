s = +"a"; t = s; t << "b"; u = s.freeze; p u.equal?(t), t.frozen?
