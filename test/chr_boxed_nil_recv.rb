# A blockless chr on a boxed receiver: an Integer is its character, a
# String its first character, and nil has no chr (NoMethodError in
# CRuby). The nil was read as a String and answered "".

def t(s)
  r = yield
  puts "#{s}: #{r.inspect}"
rescue NoMethodError => e
  puts "#{s}: #{e.class}"
end

src = [65, nil, "bc"]
t("int") { src[0].chr }
t("nil") { src[1].chr }
t("str") { src[2].chr }
