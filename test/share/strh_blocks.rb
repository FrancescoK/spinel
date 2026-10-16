# spinel: share
# spinel: gc-minor
s = +"s"
list = [s, +"t", +"u"]
list.each { |e| e << "1" }
p list, s
kept = []
list.each { |e| kept << e }
kept.each { |e| e << "k" }
p list, kept.size
def shout(x) = x << "!"
list.each { |e| shout(e) }
p list
list.each { |e| puts "#{e}:#{e.size}:#{e == s}" }
list.each { |e| next if e.size > 100; e << "n" }
p list
