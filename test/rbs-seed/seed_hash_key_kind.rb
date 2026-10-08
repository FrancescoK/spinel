# A hash parameter the seed pins to `Hash[String, untyped]`, called with a
# Symbol-keyed literal. Two hash variants of the same key kind are convertible
# -- the emitter rebuilds one from the other when only the VALUE kind differs
# -- so the contradiction rule let every same-family hash pair through. A KEY
# kind is not convertible: a Symbol-keyed hash can never satisfy this
# parameter, and the pointer went unconverted, so the callee dereferenced a
# Symbol as a `char *` and the process segfaulted (#3975).
# spinel: rbs-seed-contradicted-return
class V
  def self.render(attrs)
    out = ""
    attrs.each { |k, v| out += k.to_s + "=" + v.to_s + " " }
    out
  end
end

puts V.render({ "action" => "/x" })
puts V.render({ rel: "stylesheet" })
