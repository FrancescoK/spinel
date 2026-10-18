# A run of literal bytes every match holds -- in every branch, wherever it
# stands in each -- lets a search answer "no match" by not finding the run
# at all. Where the run is there, the search is the one it always was.

SCOPE = /(?:(?<name1>.*)::)#<Class:\k<name1>>|#<Class:(?<name2>.*)>(?:::)?/
p "Alpha::Beta::Foo::Bar".sub(SCOPE, '\k<name1>\k<name2>.')
p "Alpha::Beta::Foo::#<Class:Alpha::Beta::Foo>".sub(SCOPE, '\k<name1>\k<name2>.')
p "#<Class:Foo>::bar".sub(SCOPE, '\k<name1>\k<name2>.')
p "Alpha::Beta::Foo" =~ SCOPE, $~

# the run stands at a different distance from the start in each branch
p "a1b2 xx:=" =~ /\d+:=|x+:=/, "a1b2 xx=" =~ /\d+:=|x+:=/
p "ab-cd".scan(/\w-|-\w/), "abcd".scan(/\w-|-\w/)
p "key = value".match(/(\w+) = (\w+)|(\w+)=(\w+)/).captures

# a branch without the run means nothing is required
p "xyz" =~ /a.*=|y/, "x=z" =~ /a=|=z/

# an optional run, a run in a repetition that may not run, and a run only
# a lookaround reads are none a match has to hold
p "abd" =~ /ab(?:c)?d/, "ad" =~ /a(?:bc)*d/, "ad" =~ /a(?=d)d/
p "xay" =~ /(?<=a)y/, "y" =~ /(?<!a)y/, "ab" =~ /a(?!bc)b/

# a run in both arms of a conditional, and in one of them only
p "xab" =~ /(x)?(?(1)ab|ab)/, "cd" =~ /(x)?(?(1)ab|cd)/

# where the search starts: the run has to stand at or after it
p "ab=c=d".index(/=\w/, 3), "ab=c".index(/=\w/, 3), "a=b".match?(/=b/, 2)
p "x=y x=z".rindex(/\w=/), "x=y x=z".rindex(/\w=/, 3), "x=y".rindex(/=y/, 0)

# a match beginning before the run's first occurrence after the start
p "aaa:b".match(/a+:b/)[0], "aaa:b".gsub(/a:|:b/, "_")

# characters wider than a byte, in the run and around it
p "日本:語" =~ /.:語|語:./, "日本語" =~ /.:語|語:./, "é::é".scan(/é::|::é/)

# repeated searches over one subject: scan, gsub, split
s = "a=1, b=2, c=3"
p s.scan(/(\w)=(\d)/), s.gsub(/\w=(\d)/) { $1 * 2 }, s.split(/,\s*|;/)
p "no pairs here".scan(/(\w)=(\d)/), "no pairs here".gsub(/\w=\d/, "")
