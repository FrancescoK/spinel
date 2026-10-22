# A regexp scan of a String that is not valid UTF-8 raises ArgumentError,
# as CRuby's scanner does; a String pattern or a binary String is scanned.
require "strscan"
def t(name)
  r = yield
  puts "#{name}: #{r.inspect}"
rescue ArgumentError => e
  puts "#{name}: ArgumentError: #{e.message}"
end
t("scan_until") { StringScanner.new("abc\xE3").scan_until(/c/) }
t("scan") { StringScanner.new("abc\xE3").scan(/a/) }
t("check") { StringScanner.new("abc\xE3").check(/a/) }
t("str") { StringScanner.new("abc\xE3").scan("a") }
t("bin") { StringScanner.new("abc\xE3".b).scan_until(/c/) }
t("valid") { StringScanner.new("añb").scan_until(/b/) }
