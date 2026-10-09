s = +"a"; t = s; t << "b"; a = [s, +"ab"]; r = a.delete("ab"); p r.equal?(s), a
