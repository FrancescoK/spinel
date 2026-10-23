# A block the method yields the match to can change the subject, so a scan that
# yields from its block stays refused when the subject is not a literal.
def each_match(s)
  s.scan(/\w+/) { |m| yield m }
end
kept = []
text = +"ab cd"
each_match(text) { |w| kept << w; w << "+"; text << "z" }
p kept
