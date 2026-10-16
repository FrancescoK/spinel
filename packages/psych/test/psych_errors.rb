# Psych's exception classes, and the message and position Psych::SyntaxError
# carries for malformed documents.
require "psych"

p Psych::Exception.superclass, Psych::SyntaxError.superclass, Psych::DisallowedClass.superclass
p Psych::AliasesNotEnabled.superclass, Psych::AnchorNotDefined.superclass, Psych::BadAlias.superclass

[
  "a: b: c", "a: [1, 2", "a: [", "{a: ", "a: {b: 1", "x: -\n", "a: 1\n b: 2\n", "- a\nb: 1\n",
  "\ta: 1\n", "a: \"unterminated\n", "a: |x\n  y\n", ":sym", "a: 2024-01-01\n",
  "t: 2024-01-01 10:00:00\n", "a: &x 1\nb: *x\n", "a: !ruby/object:Foo {}\n", "a: !!set {x: }\n"
].each do |s|
  begin
    Psych.safe_load(s)
    puts "#{s.inspect} loaded"
  rescue Psych::Exception => e
    puts "#{s.inspect} #{e.class}: #{e.message}"
  end
end

begin
  Psych.safe_load("b: *nope\n", aliases: true)
rescue Psych::BadAlias => e
  puts "#{e.class}: #{e.message}"
end

begin
  Psych.load("a: [", filename: "cfg.yml")
rescue Psych::SyntaxError => e
  p [e.file, e.line, e.column, e.problem, e.context]
end
