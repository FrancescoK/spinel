# `%s` and `%p` in format, sprintf, printf and String#% count characters, not
# bytes, for their width and their precision: a multibyte value is padded to
# the width in characters, and a precision never cuts one in half.
def show(s) = puts(s.inspect)

show format("%5s|", "é")
show format("%-5s|", "é")
show format("%6s|", "日本")
show format("%-6s|", "日本")
show format("%.1s|", "日本語")
show format("%5.2s|", "日本語")
show format("%-5.2s|", "日本語")
show format("%.0s|", "日本")
show format("%s|", "日本語")
show format("%2s|", "日本語")

# combining marks and four-byte characters are characters too
show format("%4s|", "é")
show format("%3s|", "😀")
show format("%.1s|", "😀😀")

# widths and precisions given by `*`, a negative width, a name
show format("%*s|", 5, "é")
show format("%-*s|", 5, "é")
show format("%*s|", -5, "é")
show format("%.*s|", 1, "日本")
show format("%<a>5s|", a: "é")
show format("%<a>-5.1s|", a: "éé")

# %p pads and truncates its inspect text the same way
show format("%-10p|", "é")
show format("%.3p|", "日本")
show format("%8p|", :é)

# the value need not be a String
show format("%5s|", :sym)
show format("%5s|", nil)
show format("%-6s|", 12)
show format("%6s|", [1, "é"])
show format("%7s|", { "é" => 1 })

# `0`, `+`, ` ` and `#` mean nothing to a String
show format("%05s|", "ab")
show format("%+5s|% 5s|%#5s|", "y", "z", "w")

# String#%, sprintf and printf
show "%-4s|%4s|" % ["é", "日"]
show sprintf("%3s|%-3s|", "日本語", "é")
printf("%-4s|%4s|\n", "日本", "é")

# a field wider than 255 bytes
wide = format("%300s|", "é")
show wide.length
show wide[-4..]
wide = format("%-300s|", "日本")
show wide.length
show wide[0, 3]
show format("%1000s", "x").length

# invalid bytes and an embedded NUL are one character each
show format("%5s|", "a\xffb")
show format("%.2s|", "a\xffb")
show format("%3s|%-3s|", "ab\0c", "d")
show format("%5.3s|", "a\0bc")

# a size beyond what a format can hold
begin
  format("%99999999999s", "a")
rescue ArgumentError => e
  show e.message
end
begin
  format("%.99999999999s", "a")
rescue ArgumentError => e
  show e.message
end

# a negative precision is ignored, a negative width left-justifies
show format("%.*s|", -2, "abc")
show format("%-*s|", -5, "ab")

# a conversion beside it, a positional reference, a `to_s` that answers a new String
show format("%c%5s|", "é", "日")
show format("%1$5s|%1$-5s|", "é")
show format("%5s|", Class.new { def to_s = "é" + "日".dup }.new)

# sizes: digits past an Int32 are ArgumentError, an Integer argument past one is RangeError
def sized
  p yield
rescue ArgumentError, RangeError => e
  p [e.class, e.message]
end
sized { format("%2147483648s", "") }
sized { format("%.2147483648s|", "abc") }
sized { format("%*s|", 99999999999, "a") }
sized { format("%*s|", -99999999999, "a") }
sized { format("%.*s|", 99999999999, "a") }
sized { format("%*s|", 2147483648, "a") }
sized { format("%*s|", -2147483649, "a") }
