# IO#putc of a boxed value: an Integer writes its low byte, a String its
# first character, a Float its truncated low byte, and nil or a boolean is
# the conversion TypeError CRuby raises. The boxed nil wrote nothing and
# answered nil.

def t(s)
  r = yield
  puts
  puts "#{s}: #{r.inspect}"
rescue TypeError => e
  puts "#{s}: #{e.class}: #{e.message}"
end

src = [65, nil, "Bc", 66.7, true]
t("int") { $stdout.putc(src[0]) }
t("nil") { $stdout.putc(src[1]) }
t("str") { $stdout.putc(src[2]) }
t("float") { $stdout.putc(src[3]) }
t("true") { $stdout.putc(src[4]) }
t("kernel nil") { putc(src[1]) }
