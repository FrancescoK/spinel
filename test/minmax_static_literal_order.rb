# min and max of an Array literal whose elements are all static (numbers,
# nil, true, false, Symbols, Regexps, plain Strings) name an incomparable
# pair in Array#max's order, extreme first, as CRuby's prebuilt literal
# does; a literal with any other element keeps the VM's new-element-first
# order.
def t(label)
  yield
rescue => e
  puts "#{label}: #{e.message}"
end
t("nil") { [1, nil].max }
t("true") { [1, true].max }
t("false") { [1, false].max }
t("sym") { [1, :a].max }
t("str") { [1, "a"].max }
t("float") { [1.5, nil].max }
t("neg") { [-1, nil].max }
t("rational") { [1r, nil].max }
t("imag") { [1i, nil].max }
t("regexp") { [1, /x/].max }
t("range") { [1, 1..2].max }
t("array") { [1, [2]].max }
t("hash") { [1, {}].max }
t("interp") { [1, "a#{1}"].max }
t("const") { [1, Float::NAN, nil].max }
t("var") { x = nil; [1, x].max }
t("var-min") { x = nil; [1, x].min }
t("min") { [1, nil].min }
t("min-str") { ["a", 1].min }
