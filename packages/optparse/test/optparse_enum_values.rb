# A switch declared with an Array or a Hash accepts only the names in it,
# each word of a name cut as far as it stays unique, as CRuby does. An
# Array of names passes the name, a Hash or [name, value] pairs the value.
require "optparse"

def run(parser, words)
  argv = words.dup
  begin
    parser.parse!(argv)
    p argv
  rescue OptionParser::ParseError => e
    p [e.class, e.message, argv]
  end
end

symbols = OptionParser.new
symbols.on("-m", "--mode=MODE", [:fast, :slow, :fastest]) { |v| p v }
["--mode=fast", "--mode=f", "--mode=fas", "--mode=fastest", "--mode=x", "--mode=",
 "--mode=FAST", "-ms", "-mx"].each { |w| run(symbols, [w, "b"]) }
run(symbols, ["--mode", "s", "b"])
run(symbols, ["--mode", "x", "b"])

names = OptionParser.new
names.on("--level=L", ["dry-run", "dry-walk", "wet"]) { |v| p v }
["--level=d-r", "--level=d-w", "--level=w", "--level=d", "--level=dry", "--level=dry-run"].each { |w| run(names, [w]) }

hash = OptionParser.new
hash.on("--size=S", { "small" => 1, "large" => 2 }) { |v| p v }
hash.on("--color=C", { red: "#f00", green: "#0f0" }) { |v| p v }
hash.on("--speed=S", [["slow", 1], ["fast", 9]]) { |v| p v }
["--size=s", "--size=large", "--size=m", "--color=g", "--color=r", "--speed=f"].each { |w| run(hash, [w]) }

prefix = OptionParser.new
prefix.on("--a=A", ["a", "ab", "abc"]) { |v| p v }
prefix.on("--b=B", ["ab", "abc"]) { |v| p v }
prefix.on("--c=C", ["ab", "ac"]) { |v| p v }
prefix.on("--d=D", { "ab" => 1, "ac" => 1 }) { |v| p v }
prefix.on("--e=E", ["a-b", "ax-by"]) { |v| p v }
prefix.on("--f=F", [:"a-b", :"ax-by"]) { |v| p v }
prefix.on("--g=G", { "x" => 1, "xy" => 2, "xz" => 2 }) { |v| p v }
prefix.on("--h=H", ["Fast"]) { |v| p v }
["--a=a", "--b=a", "--c=a", "--d=a", "--e=a-b", "--f=a-b", "--g=x", "--h=f", "--h=Fastx"].each { |w| run(prefix, [w]) }

forms = OptionParser.new
forms.on("--opt[=O]", ["fast"]) { |v| p v }
forms.on("--[no-]neg=N", ["fast"]) { |v| p v }
forms.on("--two=T", ["fast"], { "slow" => 2 }) { |v| p v }
forms.on("--empty=E", []) { |v| p v }
forms.on("--none=N", {}) { |v| p v }
forms.on("--list=L", { "a" => [1, 2] }) { |v| p v }
[["--opt"], ["--opt=f"], ["--no-neg"], ["--neg=f"], ["--two=f"], ["--two=s"],
 ["--empty=a"], ["--none=a"], ["--list=a"]].each { |w| run(forms, w) }

typed = OptionParser.new
typed.on("--first=F", String, ["fast"]) { |v| p v }
typed.on("--last=L", ["fast"], String) { |v| p v }
typed.on("--count=C", { "10" => :ten }, Integer) { |v| p v }
typed.on("--word=W", { "one" => 1 }, Integer) { |v| p v }
typed.on("--flag=F", ["yes"], TrueClass) { |v| p v }
typed.on("--again=A", ["fast"], String, ["slow"]) { |v| p v }
["--first=f", "--last=f", "--last=x", "--count=1", "--word=o", "--flag=y", "--again=s"].each { |w| run(typed, [w]) }
