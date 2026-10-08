# A Regexp read out of a mixed Array or Hash is a pattern for String's
# split, partition, rpartition, start_with?, [] and slice!. The boxed arms
# took it for a String and raised TypeError; Rack keeps its query
# separators that way (COMMON_SEP[sep]).

SEP = { ";" => /; */n, "&" => /& */n }
R = [/b+/, "b"][0]
S = [/b+/, "b"][1]

p "a=1; b=2".split(SEP[";"])
p "a=1&b=2&c=3".split(SEP["&"], 2)
LIM = [2, nil][0]
p "a=1&b=2&c=3".split(SEP["&"], LIM + 1), "a b c".split(/ /, LIM)
s = "abbcbbd"
p s.split(R), s.split(S)
p s.partition(R), s.partition(S)
p s.rpartition(R), s.rpartition(S)
p s.start_with?(R), "bbc".start_with?(R), s.start_with?(S)
p s[R], s[S], s[R, 0], s.slice(R)
t = +"abbcbbd"
p t.slice!(R), t
u = +"abbcbbd"
p u.slice!(S), u

# a Regexp parameter, typed as one, takes the same arms
def parts(str, re) = [str.partition(re), str.rpartition(re), str.start_with?(re)]
p parts("xaay", /a+/)
v = +"xaay"
def cut(str, re) = str.slice!(re)
p cut(v, /a+/), v
