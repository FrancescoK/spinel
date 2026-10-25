# parse! and parse with into: store each switch's value under its first long
# name, or else its short one, as CRuby does: what the block returns when
# there is one, true for a flag, false for its --no- form.
require "optparse"

parser = OptionParser.new
parser.on("-x", "--xxx")
parser.on("-yYYY", "--yyy")
parser.on("-z [ZZZ]", "--zzz")
parser.on("-n N", "--num", Integer)
parser.on("--[no-]verbose")
parser.on("--dry-run")
parser.on("-s")
parser.on("--blk=B") { |v| v.upcase }
parser.on("--blknil") { |v| nil }
parser.on("--mode=M", [:fast, :slow])
parser.on_tail("--tail")

[%w[-x], %w[--yyy A], %w[-z], %w[-zQ], %w[-n 3], %w[--verbose], %w[--no-verbose],
 %w[--dry-run], %w[-s], %w[--blk=ab], %w[--blknil], %w[--mode=f], %w[--tail],
 %w[-x -x], %w[x -x y]].each do |words|
  # a Hash that starts with a Symbol key: an empty {} given as into:
  # raises TypeError for now
  options = { kept: "before" }
  argv = words.dup
  result = parser.parse!(argv, into: options)
  p [words, options, argv, result.equal?(argv)]
end

options = { yyy: "AAA" }
p parser.parse(%w[-x b], into: options)
p options
