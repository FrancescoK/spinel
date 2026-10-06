# fetch hands its block the missing key, s itself, so the append changes
# s. It appended to a copy and s stayed "abc": refused, not compiled wrong.
s = +"abc"
{}.fetch(s) { |k| k << "!" }
p s
