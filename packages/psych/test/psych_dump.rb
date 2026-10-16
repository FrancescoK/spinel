# Psych.dump writes what CRuby writes: libyaml's choice of plain, single- or
# double-quoted or literal style for each String, its folding at 80 columns,
# and its block layout (a sequence under a key at the key's own column).
require "psych"

[
  nil, true, 1, -5, 1.5, 1e20, 1.0e-7, Float::INFINITY, Float::NAN, "", "abc", "yes", "null", "~", "1",
  "1.5", "0x1f", "1:30", "08", "2024-01-01", "2024-01-01 10:00:00", ":sym", " lead", "trail ", "a: b",
  "a #b", "#c", "- x", "tab\there", "q'uote", "q\"uote", "@at", "%pct", "&amp", "*star", "|pipe",
  "[br", "?q", "a?", "x,y", "é", "\u0007bell", "a\u0000b", "-", "---", "a:", "a:b", "'", "\"",
  "<<", "y", "N", "multi\nline", "multi\nline\n", "a\n\n", "\n", " x\ny", "x\n y\n",
  "long " * 30, "word " * 20 + "end", "a" * 100, "x\ty " * 30, :sym, :"x y",
  [], {}, [1, "a", nil], [[[]]], [{}],
  { "a" => 1, "b" => [1, 2], "c" => { "d" => "e" }, "e" => [], "f" => {} },
  [{ "a" => 1, "b" => 2 }, [1, 2], []],
  { "deep" => { "er" => { "est" => [1, { "k" => "v" }] } } },
  { 1 => "one", true => "t", nil => "n", :s => 1 },
  { "k" => "multi\nline", "multi\nkey" => 1 }
].each { |v| print v.inspect, " => ", Psych.dump(v).inspect, "\n" }

puts({ "a" => [1, 2] }.to_yaml)
p Psych.safe_dump({ "a" => 1 })
begin
  Psych.safe_dump({ "a" => :b })
rescue Psych::DisallowedClass => e
  puts e.message
end
p Psych.safe_dump({ "a" => :b }, permitted_classes: [Symbol])
