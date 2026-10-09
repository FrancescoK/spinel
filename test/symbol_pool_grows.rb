# A program that makes more than 8,192 Symbols at run time keeps them apart.
h = {}
9_000.times { |i| h[("k" + i.to_s).to_sym] = i }
p h.size
p h[("k" + "8191").to_sym], h[("k" + "8192").to_sym], h[("k" + "8999").to_sym]

syms = []
500.times { |i| syms << :"n#{i}" }
p syms.uniq.size
p syms[250], syms.last
p syms.count { |y| y.to_s.start_with?("n") }

names = (0...500).map { |i| "w" + i.to_s }
back = names.map(&:to_sym)
p back.each_with_index.count { |y, i| y.to_s != names[i] }
p back[400] == ("w" + "400").to_sym, back[400] == back[401]
