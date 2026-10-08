# A boxed needle that is a String the rule shares is matched by contents:
# include?, index, delete, and MatchData#[] by name.
names = "a\nmathx\nb".split("\n")
def find(list, name) = list.include?(name)
n = +"mathx"; n2 = n; n2 << ""
box = [n, 1][0]
p find(names, box), names.index(box), names.include?(box)
m = /(?<word>[a-z]+)/.match("hello")
key = [+"word", 1][0]
p m[key]
p names.delete(box), names

# Missing values keep the fallback argument itself; nil stays distinct.
s = +"hit"; t = s; t << "!"
b = [s, 1][ARGV.size]
a = ["hit!", "other", "hit!", nil]
p a.include?(b), a.index(b), a.rindex(b)
p a.delete(b) { |x| x.equal?(b) }, a
p a.delete(b) { |x| x.equal?(b) }
n = [nil, 1][ARGV.size]
p a.include?(n), a.index(n), a.delete(n)
k = +"wor"; l = k; l << "d"
key = [k, 1][ARGV.size]
m = /(?<word>[a-z]+)/.match("hello")
p m[key], m.values_at(key)
