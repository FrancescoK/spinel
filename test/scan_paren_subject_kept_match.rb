# A match `scan` hands its block is kept and then appended to, where the
# String scanned and the Array keeping the matches are values in
# parentheses after another statement: each match is its own String, as
# without the parentheses.
n = 0
acc = (n += 1; [])
(n += 1; "a1b2").scan(/[a-z]/) { |m| acc << m; m << "*" }
p acc
s = +"x9y8"
kept = (n += 1; [])
(n += 1; s).scan(/\d/) { |d| kept << d; d << "!" }
p kept, s, n
