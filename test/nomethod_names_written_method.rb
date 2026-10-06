# A NoMethodError names the method the program called, and its receiver,
# as CRuby's does. A call lowered through another method named that one:
# detect through find, min(n) { } through sort, min_by through its walk,
# String#slice and Hash#slice through #[], magnitude, imag and conj through abs, imaginary
# and conjugate. keys, values and compare_by_identity? on a boxed
# nil left out "for nil" or said "for poly". And append_as_bytes words its
# TypeError as CRuby does, takes an Integer's low byte, runs its receiver once,
# and checks a nil receiver, then its operands, then a frozen receiver.

def t(k)
  r = k == 0 ? nil : {"a" => +"x"}
  q = k == 0 ? nil : [1, 2]
  s = k == 0 ? nil : +"ab"
  b = [nil, [1, 2]][k]
  i = [7, [1, 2]][k]
  h = [nil, {"a" => 1}][k]
  str = +"ab"
  log = []
  [-> { r.detect { |kk, v| v } }, -> { q.detect { |v| v } }, -> { b.detect { |v| v } },
   -> { i.detect { |v| v } }, -> { b.collect_concat { |v| [v] } },
   -> { q.min(1) { |x, y| x <=> y } }, -> { q.max(1) { |x, y| x <=> y } },
   -> { r.min_by(1) { |*a| a } }, -> { b.max_by { |v| v } },
   -> { s.slice(1) }, -> { s.slice(0, 1) }, -> { (+"ab").slice(1) },
   -> { h.keys }, -> { h.values }, -> { h.compare_by_identity? }, -> { [7, {1 => 2}][k].keys },
   -> { str.append_as_bytes(nil) }, -> { str.append_as_bytes([[7], "x"][k]) },
   -> { str.append_as_bytes(1.5) }, -> { (+"").append_as_bytes(321, [66, "x"][k], "c") },
   -> { [nil, 1i][k].magnitude }, -> { [nil, 1i][k].imag }, -> { [:s, 1i][k].conj },
   -> { [nil, 3][k].abs }, -> { (log << :r; str).append_as_bytes((log << :a0; 65), (log << :a1; [66, nil][k])) },
   -> { "ab".freeze.append_as_bytes(nil) }, -> { "ab".freeze.append_as_bytes(65) },
   -> { s.append_as_bytes(nil) }, -> { r.detect(1) { |*a| a[0] } }, -> { [nil, [1, 2].each][k].detect(1) },
   -> { [nil, (0.5...3.0)][k].min_by }, -> { r.slice(1) }, -> { [7, {1 => 2}][k].slice(1) }].each do |f|
    p f.call
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
  p log
end
t(ARGV.size)
