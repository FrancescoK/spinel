# spinel: not-cruby -- CRuby's Psych builds a Date, Time, Regexp or a program's own object; this package raises NotImplementedError naming it.
# A node Psych would build as an object of a class this package cannot make
# (once the load permits the class, or under unsafe_load), freeze: true, an
# Encoding and an ordered map raise NotImplementedError instead of answering
# a String or a Hash in their place. So does dumping a value Psych would tag.
require "psych"

[
  -> { Psych.safe_load("a: 2024-01-01", permitted_classes: ["Date"]) },
  -> { Psych.unsafe_load("t: 2024-01-01 10:00:00") },
  -> { Psych.unsafe_load("a: !ruby/regexp /x/") },
  -> { Psych.unsafe_load("a: !ruby/object:Foo {}") },
  -> { Psych.unsafe_load("a: !!set {x: }") },
  -> { Psych.safe_load("a: !ruby/encoding UTF-8") },
  -> { Psych.safe_load("a: !!omap [b: 1]") },
  -> { Psych.safe_load("a: 1", freeze: true) },
  -> { Psych.dump({ [1] => 2 }) },
  -> { Psych.dump(1..2) }
].each do |f|
  begin
    p f.call
  rescue NotImplementedError => e
    puts e.message
  end
end
