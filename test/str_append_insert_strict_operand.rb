# String#<<, #concat and #prepend take a String or, for << and concat, an
# Integer codepoint; #insert takes a String. Anything else is CRuby's
# TypeError. A boxed operand of the statement form of <<, and of insert on
# any receiver, was stringified instead: nil appended nothing, 65 appended
# "65", and a typed receiver's insert of a boxed operand did not build.
# The statement form of concat on a String local (cat) stringified a boxed
# operand the same way.

def cat(b)
  s = +"He"
  s.concat(b, "!")
  s
end

def t(k)
  out = []
  r = [+"He", :x][0]
  [nil, 65, 1.5, :s, [1], +"z"].each do |b0|
    b = [b0, 0][k]
    [-> { s = +"He"; s << b; s }, -> { s = +"He"; s << "a" << b; s }, -> { @s = +"He"; @s << b; @s },
     -> { s = +"He"; s.concat(b); s }, -> { s = +"He"; s.concat("a", b); s }, -> { s = +"He"; s.prepend(b); s },
     -> { s = +"He"; s.insert(1, b); s }, -> { s = +"He"; x = s.insert(1, b); x }, -> { r.dup.insert(1, b) },
     -> { s = +"He"; s.insert(-1, b); s }, -> { (+"He" << b).size }].each_with_index do |f, i|
      out << "#{i} #{f.call.inspect}"
    rescue => e
      out << "#{i} #{e.class}: #{e.message}"
    end
    out << "cat #{cat(b).inspect}"
  rescue => e
    out << "cat #{e.class}: #{e.message}"
  end
  puts out
end

t(ARGV.size)
