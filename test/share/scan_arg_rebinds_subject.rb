# scan with a block answers its receiver: the String the subject's local
# named when the call read it, even where an argument rebinds the local
# (#9258)
def k(t, acc)
  r = t.scan((t = +"xy"; /./)) { |m| acc << m }
  [acc, r, t]
end
p k(+"abc", [])
