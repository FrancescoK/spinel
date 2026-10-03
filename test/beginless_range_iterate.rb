# Enumerating a beginless Range raises TypeError, "can't iterate from
# NilClass". The literal `(..3).each` did; a beginless Range held in a
# variable, or built at run time from a nil beginning, walked up from
# INTPTR_MIN instead, and its first value read back as nil.

def t(s)
  r = yield
  puts "#{s}: #{r.inspect}"
rescue TypeError => e
  puts "#{s}: #{e.class}: #{e.message}"
end

src = [1, nil]
r = (..3)
q = src[1]..3
t("literal each") { x = []; (..3).each { |i| x << i; break if x.size > 2 }; x }
t("var each") { x = []; r.each { |i| x << i; break if x.size > 2 }; x }
t("run-time each") { x = []; q.each { |i| x << i; break if x.size > 2 }; x }
t("var for") { x = []; for i in r; x << i; break if x.size > 2; end; x }
t("var to_a") { r.to_a }
t("run-time map") { q.map { |i| i } }
t("run-time sum") { q.sum }
t("include?") { q.include?(-9) }
t("bounded") { x = []; (src[0]..3).each { |i| x << i }; x }
