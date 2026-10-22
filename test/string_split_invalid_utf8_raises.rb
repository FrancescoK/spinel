# Splitting a UTF-8 String that is not valid UTF-8 raises ArgumentError, as
# in CRuby, in every separator mode; a binary String, an empty one, and a
# limit of 1 (the String whole, unread) are answered.
def t(name)
  r = yield
  puts "#{name}: #{r.inspect}"
rescue ArgumentError => e
  puts "#{name}: ArgumentError: #{e.message}"
end
s = "a\xff b,c"
t("split") { s.split }
t("split nil") { s.split(nil) }
t("split space") { s.split(" ") }
t("split space limit") { s.split(" ", 2) }
t("split comma") { s.split(",") }
t("split comma -1") { s.split(",", -1) }
t("split comma 2") { s.split(",", 2) }
t("split empty") { s.split("") }
t("split limit 1") { s.split(",", 1) }
t("split space limit 1") { s.split(" ", 1) }
t("split empty string") { "".split(",") }
t("split binary") { s.b.split(" ") }
t("split valid") { "é b,c".split(" ") }
