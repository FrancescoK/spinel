# upcase, downcase, capitalize and swapcase take their options with or
# without a block, which they ignore. Two options and three were counts no
# argument list of the generator's showed taking the block, so a boxed
# receiver's call kept it and found no arm: NoMethodError where CRuby
# answers or raises its ArgumentError.

def t(k)
  log = []
  r = [:ab, 7][k]
  s = [+"ab", 7][k]
  q = k == 0 ? :cd : nil
  [-> { r.upcase(:turkic, :lithuanian) { log << 1 } }, -> { r.upcase(1.5, 1.5) { log << 2 } },
   -> { r.downcase(:a, :b, :c) { log << 3 } }, -> { r.capitalize(:turkic, :x) { log << 4 } },
   -> { s.swapcase(:lithuanian, :turkic) { log << 5 } }, -> { s.downcase(:fold, :turkic, 1) { log << 6 } },
   -> { q.upcase(:turkic, :lithuanian) { log << 7 } }, -> { q.capitalize(1, 2, 3) { log << 8 } },
   -> { :ab.swapcase(1, 2, 3) { log << 9 } }, -> { "ab".upcase(:turkic, :lithuanian) { log << 10 } }].each do |f|
    p f.call
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  p log
end

t(ARGV.size)
