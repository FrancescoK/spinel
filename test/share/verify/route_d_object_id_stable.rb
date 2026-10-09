s = +"a"; t = s; t << "b"; a = s.object_id; s << "c"; p a == s.object_id, a == t.object_id
