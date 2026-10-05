# A block whose only parameter is a splat (`{ |*b| ... }`) given to a builtin
# iterator: CRuby packs the values each step yields into the splat (one for
# most, two for each_with_object, chunk_while and a comparator, three for a
# merge's conflict). Spinel's lowerings bind named parameters only, and stopped the
# compiler, raised NoMethodError (chunk) or bound nil (merge!).

def t(k)
  h = {1 => 2, 3 => 4}
  a = [3, 1, 2]
  [-> { a.count { |*b| b[0] > 1 } }, -> { a.any? { |*b| b[0] > 2 } }, -> { a.one? { |*b| b.size == 1 } },
   -> { a.find_index { |*b| b[0] == 1 } }, -> { a.min_by { |*b| b[0] } }, -> { a.max_by { |*b| -b[0] } },
   -> { a.sum { |*b| b[0] } }, -> { a.uniq { |*b| b[0] % 2 } }, -> { h.count { |*b| p b; true } },
   -> { a.each_with_object([]) { |*b| b[1] << b[0] } }, -> { a.each_slice(2).map { |*b| b } },
   -> { a.sort_by { |*b| b[0] } }, -> { a.cycle(1) { |*b| p b } }, -> { (1..3).sum { |*b| b[0] } },
   -> { [1, 2, 4].chunk_while { |*b| b[1] == b[0] + 1 }.to_a }, -> { a.index { |*b| b[0] == 2 } },
   -> { [1, 3].bsearch { |*b| b[0] >= 2 } }, -> { a.min_by(2) { |*b| b[0] } },
   -> { [1, 2, 3].chunk { |*b| b[0].odd? }.to_a }, -> { {1 => 2}.merge!({1 => 4}) { |*b| b[1] } },
   -> { {1 => 2}.update({1 => 4}) { |*b| b[2] } }, -> { a.none? { |*b| b.empty? } },
   -> { r = []; "ab cd".split { |*b| r << b }; "a\nb".lines { |*b| r << b }; "ab".chars { |*b| r << b }; r },
   -> { r = []; "ab".codepoints { |*b| r << b }; ("a".."b").step(1) { |*b| r << b }; r },
   -> { [a.sort { |*b| b[0] <=> b[1] }, a.min { |*b| b[0] <=> b[1] }, a.max(2) { |*b| b[0] <=> b[1] }] },
   -> { a.minmax { |*b| b[0] <=> b[1] } }].each do |f|
    p f.call
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
end
t(ARGV.size)
