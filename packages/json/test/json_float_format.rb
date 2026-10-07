# JSON.generate writes a Float as the json generator does, which is not
# always Float#to_s: a whole number with ".0" while its exponent is under 15,
# a plain decimal down to 1e-7 (or with an exponent under 10), and
# scientific notation otherwise, the exponent unpadded.
require "json"
vals = [0.0, -0.0, 1.0, -2.5, 100.0, 1e14, 1e15, 1.23456789012345e14,
        1.234567890123456e15, 0.1, 1e-6, 1e-7, 1.5e-7, 1.234e-9, 5e-324,
        1.7976931348623157e308, 3.14159, 2.0**60, 1e22, 1e-10,
        0.000123456789, 12.5e-8, -1e20, 1e100, 1e-5]
vals.each { |v| puts JSON.generate(v) }
puts JSON.generate({ "a" => 1e20, "b" => [1.5e-7, 2.5] })
puts [1e16, 0.5].to_json
