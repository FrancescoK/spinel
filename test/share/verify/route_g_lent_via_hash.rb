@h = {k: +"a"}
def f(s) = (@h[:k] << "zzz"; s.size)
p f(@h[:k])
