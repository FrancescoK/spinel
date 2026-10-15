# spinel: int64
# A Bignum handed to an Integer argument the method reads as a C long
# raises RangeError, as CRuby does, typed or boxed, instead of reading the
# Bignum's low word (`a.delete_at(2**70)` deleted a[0]). One that fits the
# slot is its value. A method that takes any Integer there (a bit test, a
# bit index, pow's modulus, Integer.sqrt, a seed) answers as CRuby does.
def t(label)
  r = yield
  puts "#{label}: #{r.inspect}"
rescue RangeError, Math::DomainError => e
  puts "#{label}: #{e.class}"
end

big = [2**70, 1][0]
fits = [(2**70) >> 69, 1][0]

a = [:x, :y, :z]
t("delete_at") { a.delete_at(big) }
p a
t("take") { [1, 2, 3].take(big) }
t("drop") { [1, 2, 3].drop(big) }
t("center") { "ab".center(big) }
t("byteslice") { "Zz9".byteslice(big) }
m = /(a)(b)/.match("xab")
t("offset") { m.offset(big) }

# boxed receiver
class Box
  def take(n) = [:box, n]
end
def tk(o, n) = o.take(n)
t("boxed take") { tk([[1, 2, 3], Box.new][0], big) }
t("boxed take, fits") { tk([[1, 2, 3], Box.new][0], fits) }
t("take, fits") { [1, 2, 3].take(fits) }
t("delete_at, fits") { [:x, :y, :z].delete_at(fits) }

# any Integer
b1 = [2**70 + 1, 1][0]
nb = [-(2**70), 1][0]
t("anybits?") { [5.anybits?(big), 5.anybits?(b1), (-1).anybits?(big), 5.anybits?(nb)] }
t("nobits?") { [5.nobits?(big), 5.nobits?(b1), (-5).nobits?(big), 5.nobits?(nb)] }
t("allbits?") { [5.allbits?(big), (-1).allbits?(big), (-5).allbits?(nb)] }
t("bit") { [5[big], 5[b1], (-5)[big], 5[nb]] }
t("pow") { [5.pow(2, big), 5.pow(3, b1)] }
t("sqrt") { [Integer.sqrt(big), Integer.sqrt(b1)] }
t("sqrt, negative") { Integer.sqrt(nb) }
r1 = Random.new(big).rand(1000)
r2 = Random.new(big).rand(1000)
t("seed") { r1 == r2 }
srand(big)
x1 = rand(1000)
srand(big)
t("srand") { x1 == rand(1000) }
