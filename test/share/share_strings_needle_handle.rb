# Flag-only: without the flag (as on master) these needles match nothing.
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
