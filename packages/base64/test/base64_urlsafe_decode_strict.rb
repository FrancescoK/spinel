require "base64"

# urlsafe_decode64 is CRuby's: input that does not end in `=` is padded to a
# multiple of 4, `-_` read as `+/` (so `+/` themselves pass), and the result
# decoded as strictly as strict_decode64 -- whitespace, a stray byte, a
# misplaced or extra `=`, or padding over bits that are not zero raise
# ArgumentError. strict_decode64 rejects the last as well.
def show(name, s)
  r = yield(s).bytes.inspect
rescue ArgumentError => e
  r = "ArgumentError: #{e.message}"
ensure
  puts "#{name} #{s.inspect} => #{r}"
end
["", "YQ", "YQ==", "YWI", "YWI=", "YWJj", "-_-_", "+/+/", "a+b/", "_w", "_w==",
 "YQ=", "YQ===", "Y", "=YQ", "Y Q==", "YQ\n", "YQ!=", "YQ==YQ==", "8V==", "8V", "I2M2F3R=", "I2M2F3Q="].each do |s|
  show("urlsafe", s) { |x| Base64.urlsafe_decode64(x) }
end
["8V==", "8Q==", "I2M2F3R=", "I2M2F3Q="].each do |s|
  show("strict", s) { |x| Base64.strict_decode64(x) }
end
