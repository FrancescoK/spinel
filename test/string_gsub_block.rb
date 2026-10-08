# Issue #849: gsub / sub with a block — block receives the
# matched substring and its return value is the replacement.
# spinel: wasm
puts "hello".gsub(/./) { |c| c.upcase }
puts "hello world".gsub(/\w+/) { |w| w.length.to_s }
puts "abc".sub(/b/) { |c| c.upcase }
# Block return is concatenated verbatim — backref expansion
# does not run on block returns (Ruby semantics).
puts "ab".gsub(/(a)(b)/) { |m| "[" + m + "]" }
