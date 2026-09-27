# A boxed `**` operand that is a user object converts through #to_hash, and
# no class here defines one (or method_missing), so it is CRuby's TypeError,
# ahead of a literal key naming no member as well.
Named = Struct.new(:a, :b, keyword_init: true)
class Bare; end
def k(a: 0, b: 0) = [a, b]

def try
  p yield
rescue ArgumentError, TypeError => e
  puts "#{e.class}: #{e.message}"
end

[{ b: 2 }, Bare.new].each do |v|
  try { Named.new(**v) }
  try { Named.new(c: 1, **v) }
  try { k(**v) }
end
