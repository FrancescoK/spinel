# A block that writes the local the scan walks rebinds the name, never
# the String the scan walks, so the scan goes on over its own matches.
acc = []
s = +"abc"
s.scan(/./) { |m| acc << m; m << "!"; s = +"other" if m == "a!" }
p acc, s
