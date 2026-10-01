# A method that matches gives back its caller's $~ on return (#3629); $` and
# $' are built lazily from the match's span, which comes back with it, so the
# caller reads its own pre and post match, not the callee's offsets.
def inner_sub
  "uvwxyz".sub("v", "!")
end
"abcde".sub("c", "!")
inner_sub
p $`, $'

def inner_match
  "uvwxyz" =~ /v/
end
"abcde" =~ /c/
inner_match
p $`, $'

def inner_gsub
  "uvwxyz".gsub(/[wy]/, "!")
end
"abcde".gsub(/b|d/, "!")
inner_gsub
p $`, $', $~[0]
