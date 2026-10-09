s = +"a"; t = s; t << "b"; u = String.new(s); u << "!"; p s, u, u.equal?(s)
