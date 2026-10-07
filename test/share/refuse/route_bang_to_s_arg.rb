# Flag-only: under --share-strings, `t.strip!.to_s` answers t itself when
# strip! changed it, but the argument takes it as a copy, so grow's append
# would miss t: refused.
def grow(b)
  b << "!"
  nil
end
t = +" b "
grow(t.strip!.to_s)
p t
