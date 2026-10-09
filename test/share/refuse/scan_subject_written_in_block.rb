# A block that writes the local the scan walks is refused too, whatever it
# stores there.
acc = []
s = +"abc"
s.scan(/./) { |m| acc << m; m << "!"; s = +"other" if m == "a!" }
p acc, s
