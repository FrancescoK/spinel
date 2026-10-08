# The other half of the #3975 rule: a hash whose VALUE kind differs from the
# seed is convertible and must still compile. Only the KEY kind is a
# contradiction.
# spinel: rbs-seed-run
class V
  def self.render(attrs)
    out = ""
    attrs.each { |k, v| out += k.to_s + "=" + v.to_s + " " }
    out
  end

  def self.take_sym(h)
    h.size
  end
end

puts V.render({ "a" => "1", "b" => "2" })
puts V.render({ "a" => 1 })
puts V.render({ "a" => 1, "b" => "x" })
puts V.take_sym({ a: 1, b: 2 })
