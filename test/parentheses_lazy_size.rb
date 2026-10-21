# Parenthesized endless sources answer Infinity and run their prefix once.
p (puts :endless; (1..)).lazy.size
p (puts :infinite; (1..Float::INFINITY)).lazy.size
p (puts :finite; (1..5)).lazy.size
p (0; [1, 2]).lazy.size
p ((1..)).lazy.take(3).size
p (puts :take; (1..)).lazy.take(3).size
