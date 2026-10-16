# Tagged nodes read as Psych::Visitors::ToRuby reads them: a tag decides even
# on a quoted scalar (`!!int '2'` is 2), an unknown tag resolves the value as
# untagged, `!!float` goes through Float(), and a tag naming a class asks the
# class loader first, so an unpermitted class raises DisallowedClass with its
# name. Properties on an implicit key's line belong to the key.
require "psych"

[
  "a: ! 3", "a: ! '3'", "a: !!int '2'", "! '': nil key", "a: !!str 1", "a: !<tag:yaml.org,2002:str> 1",
  "[!!str 1, !!int '4', !!float 2, !ruby/foo 1, !custom 1]", "a: !!null x", "a: !!bool x", "a: !!int x",
  "a: !!int", "a: !!str", "a: !!binary aGk=", "a: !!timestamp x", "a: !!foo {b: 1}", "a: !!seq {b: 1}",
  "a: !!map [1]", "a: !!pairs [b: 1, c: 2]", "a: !!set [x]", "a: !!str {str: x}", "a: !!str {}",
  "a: !ruby/object:Hash {b: 1}", "a: !!str |\n  x\n", "a: !!int |\n  2\n", "&k key: v\nother: *k\n",
  "- !!str 1: x\n", "a: !!float x", "a: !!float ~", "a: !!float true", "a: !!str {b: 1}",
  "a: !ruby/regexp /x/", "a: !ruby/range 1..2", "a: !ruby/class String", "a: !ruby/object {}",
  "a: !ruby/object:Foo {}", "a: !ruby/struct {b: 1}", "a: !ruby/struct:Foo {}", "a: !ruby/exception {}",
  "a: !ruby/array:Foo []", "a: !ruby/hash:Foo {}", "a: !ruby/string:Foo x", "a: !ruby/object:Complex x",
  "a: !!set {x: }", "a: !!omap {b: 1}", "a: !!timestamp 2024-01-01", "a: !ruby/sym x"
].each do |s|
  begin
    puts "#{s.inspect} => #{Psych.safe_load(s, aliases: true).inspect}"
  rescue Psych::Exception, ArgumentError, TypeError, FrozenError => e
    puts "#{s.inspect} #{e.class}: #{e.message}"
  end
end
