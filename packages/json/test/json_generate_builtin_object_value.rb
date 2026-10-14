# A Time, a Range or a Rational inside a Hash or an Array generates as its
# #to_s, as CRuby's json generates any object without a #to_json of its own.
require "json"

time = Time.at(0).utc
puts JSON.generate({ "t" => time })
puts JSON.generate([time, 1])
puts({ "t" => time }.to_json)
puts JSON.pretty_generate({ "t" => time })
puts JSON.generate({ "range" => (1..3), "rational" => Rational(1, 3) })
