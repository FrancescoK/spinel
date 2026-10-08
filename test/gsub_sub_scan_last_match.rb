# gsub, sub, scan and their bang forms leave `$~` at their last match, or nil
# when nothing matched, whether the pattern is a String or a Regexp. A String
# pattern's `$~.regexp` is the String escaped into a Regexp. Inside a block,
# `$~` is that turn's match. A method doing one keeps its caller's `$~`, and
# slice!, index and the other String-pattern searches leave `$~` alone.
# spinel: gc-minor
def md(m) = m.nil? ? nil : [m[0], m.regexp, m.pre_match, m.post_match, m.begin(0)]

'he[[o'.gsub('[', ']')
p $~.regexp, $~[0], $&, $`, $'

s = "he[[o"
pat = "["
"xx" =~ /x/; s.gsub(pat, "]"); p md($~)
"xx" =~ /x/; s.gsub("z", "]"); p md($~)
"xx" =~ /x/; s.sub(pat, "]"); p md($~)
"xx" =~ /x/; s.sub("z", "]"); p md($~)
"xx" =~ /x/; t = +"he[[o"; t.gsub!("[", "]"); p md($~)
"xx" =~ /x/; t = +"he[[o"; t.sub!("z", "]"); p md($~)
"xx" =~ /x/; s.scan("["); p md($~)
"xx" =~ /x/; s.scan("z"); p md($~)
"xx" =~ /x/; s.sub("[", "[" => "<"); p md($~)
"abc".gsub("", "-"); p $~.begin(0)
"abc".scan(""); p $~.begin(0)

s.scan("[") { |x| p md($~) }
p md($~)
r = "a-b-c".scan("-") { |x| p $~.begin(0) }
p r
p s.gsub("[") { |x| p md($~); "]" }
p md($~)
"xx" =~ /x/; s.gsub("z") { |x| "]" }; p md($~)
t = +"he[[o"; t.sub!("[") { |x| p md($~); "]" }; p md($~)
v = [1, "he[[o"][1]
v.scan("[") { |x| p $~.begin(0) }
v.gsub("[", "]"); p md($~)

"xx" =~ /x/; s.gsub(/\[/, "]"); p md($~)
"xx" =~ /x/; s.gsub(/z/, "]"); p md($~)
"xx" =~ /x/; s.sub(/\[/, "]"); p md($~)
"xx" =~ /x/; "a1b22".scan(/(\d)(\d)?/); p md($~), $1, $2
"xx" =~ /x/; s.gsub(/\[/) { |x| "]" }; p md($~)
"xx" =~ /x/; s.gsub(/[\[o]/, "[" => "<", "o" => "0"); p md($~)
"xx" =~ /x/; t = +"he[[o"; t.sub!(/\[/, "]"); p md($~)

def esc(s) = s.gsub("&", "&amp;")
def any_gsub(s, pat) = s.gsub(pat, "#")
"xx" =~ /x/
p esc("a&b"), any_gsub("a.b", "."), any_gsub("a.b", /\./), md($~)

"xx" =~ /x/
u = +"he[[o"; u.slice!("[")
"he[[o".index("["); "he[[o".partition("["); "he[[o".split("[")
p u, md($~)
