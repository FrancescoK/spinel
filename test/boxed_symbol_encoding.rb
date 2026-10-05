# encoding on a value read out of a mixed Array: a Symbol is US-ASCII when
# its name is all ASCII and UTF-8 otherwise, a String keeps its own, and
# any other kind raises NoMethodError.
p [:hello, 1][0].encoding
p [:"héllo", 1][0].encoding
p [+"hello", 1][0].encoding
p ["hello".b, 1][0].encoding
p [:hello, 1][0].encoding == Encoding::US_ASCII
begin
  [1, :a][0].encoding
rescue NoMethodError => e
  puts e.message
end
