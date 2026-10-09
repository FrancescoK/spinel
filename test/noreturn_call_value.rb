def fr = raise("fr")
def ft; throw :t, 7; end
def fz; exit(0); end
def cond(x) = x ? raise("c") : 5
def q; puts "hi"; end

class K
  def boom = raise("k")
end

def t
  yield
rescue => e
  e.message
end

k = K.new
p t { 1 }
p t { "s" }
p t { fr }
p t { k.boom }
p t { cond(false) }
p t { cond(true) }
p t { q }
p(catch(:t) { t { ft } })
p [1, 2].map { |i| t { i == 1 ? i : fr } }
p t { fz }
puts "unreachable"
