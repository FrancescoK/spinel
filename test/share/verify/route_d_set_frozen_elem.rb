require "set"; s = +"v"; t = s; t << "!"; st = Set[s]; e = st.first; p e.frozen?, e.equal?(s)
