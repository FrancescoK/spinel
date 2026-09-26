# sub / gsub (and the bang forms) whose PATTERN is a value that is a Regexp
# or a String only at runtime -- an inflection rule read out of a
# [pattern, replacement] pair. The string-pattern path coerced the Regexp
# ("no implicit conversion of Regexp into String"); the pattern's tag now
# picks the engine.
rules = [[/(bus)$/i, '\1es'], [/(x|ch|ss|sh)$/i, '\1es'], [/s$/i, "s"], [/$/, "s"]]
def apply(word, rules)
  result = word.dup
  rules.each { |(rule, replacement)| break if result.sub!(rule, replacement) }
  result
end
p apply("bus", rules), apply("box", rules), apply("cart", rules), apply("cats", rules)
mixed = [["person", "people"], [/x$/, "y"], ["o", "0"]]
p apply("person", mixed), apply("box", mixed), apply("foo", mixed)
def all(word, rules)
  result = word.dup
  rules.each { |(rule, replacement)| result = result.gsub(rule, replacement) }
  result
end
p all("boss", [["s", "z"], [/z+/, "Z"]]), all("aaa", [[/a/, "b"], ["bb", "c"]])
def bang_all(word, rules)
  result = word.dup
  changed = 0
  rules.each { |(rule, replacement)| changed += 1 if result.gsub!(rule, replacement) }
  [result, changed]
end
p bang_all("mississippi", [[/ss/, "S"], ["i", "!"], [/zzz/, "-"]])
odd = [3, "z"]
begin
  "x".sub(odd[0], "y")
rescue TypeError => e
  puts "TypeError: #{e.message}"
end
