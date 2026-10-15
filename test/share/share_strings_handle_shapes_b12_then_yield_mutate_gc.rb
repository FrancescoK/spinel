# Under --share-strings the String stays one object under every name the
# program gives it: a change through one name shows through the others, and
# equal? holds.
s = +"abc"
200.times do |i|
  s.then { |q| q << ("x" * 0); t = "y" * 100; q << i.to_s if i % 100 == 0 }
end
p s
