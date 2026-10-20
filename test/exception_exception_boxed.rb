# Exception#exception through an Array element: the receiver itself with no
# argument or with itself, else a copy of it carrying the new message, as the
# typed receiver answers; NoMethodError for a value that is no exception
def t(label)
  r = yield
  p [label, r.class, r]
rescue NoMethodError => e
  puts "#{label}: #{e.message}"
end
e = [RuntimeError.new("x"), 0][0]
t("message") { e.exception("y") }
t("self") { e.exception.equal?(e) }
t("given self") { e.exception(e).equal?(e) }
t("copy") { e.exception("y").equal?(e) }
t("receiver kept") { e.message }
t("symbol message") { e.exception(:sym).message }
class AppError < StandardError; end
m = [AppError.new("m"), 1][0]
t("subclass") { m.exception("n") }
t("not an exception") { [1, 2][0].exception("z") }
# nil is no message, so the class name answers; a String message is the
# String itself, so a later append shows through it
t("nil message") { e.exception(nil).message }
s = +"mut"
x = e.exception(s)
s << "!"
t("string kept") { x.message }
