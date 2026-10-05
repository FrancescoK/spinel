# CRuby 4.0's strip, lstrip and rstrip take selectors: the characters every
# selector holds (each read as String#delete reads it, a range, a leading ^
# negating) are stripped instead of whitespace. Spinel ignored them, on a
# typed and on a boxed receiver, and the bang forms answered nil. And a
# boxed operand of String#concat or #<< that is no String (nor an Integer
# codepoint) is CRuby's TypeError, where its rendering was appended.

def strips(k)
  s = +"xxabxx"
  [-> { s.strip("x") }, -> { s.lstrip("x") }, -> { s.rstrip("x") },
   -> { "xyabyx".strip("x", "xy") }, -> { "abc".lstrip("a-b") }, -> { "\tab\n".rstrip("^a") },
   -> { "aab".lstrip("") }, -> { "xxx".strip("x") }, -> { "éaé".strip("é") },
   -> { s.strip(nil) }, -> { s.strip(1) }, -> { s.rstrip("x", nil) },
   -> { [+"xxab", :x][k].lstrip("x") }, -> { [+"abyy", :x][k].rstrip("y") },
   -> { [:x, +"ab"][k].strip("x") },
   -> { t = +"xxabxx"; [t.strip!("x"), t] }, -> { (+"ab").strip!("x") },
   -> { t = +"xxab"; [t.lstrip!("x"), t] }, -> { (+"abxx").rstrip!("x", nil) },
   -> { t = [+"xxab", :x][k]; [t.lstrip!("x"), t] },
   -> { "  ab \0".rstrip }, -> { " \0ab".lstrip }].each do |f|
    p f.call
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
end

def appends(k)
  [-> { (+"ab").concat([[7], "x"][k]) }, -> { (+"ab").concat([1.5, "x"][k]) },
   -> { (+"ab").concat("c", [nil, "x"][k]) }, -> { (+"ab") << [:s, "x"][k] },
   -> { (+"ab") << [100, "x"][k] }, -> { (+"ab") << ["cd", 1][k] },
   -> { (+"ab").prepend([[7], "x"][k]) }].each do |f|
    p f.call
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
end

strips(ARGV.size)
appends(ARGV.size)
