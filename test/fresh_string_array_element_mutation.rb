# A String yielded out of a fresh Array (split, scan) and mutated in place
# where nothing can read the mutation back through that Array: the Array is
# a call's temporary whose iterator answer is dropped or is the block's
# values, or a map!/collect! stores each block value over its element.
# These were refused ("not yet shared by reference") although a copy gives
# the same answer. Actionview's highlight and split_paragraphs and rack's
# parse_http_accept_header are written so.

# highlight: each answers the scanned Array and join reads it, so each
# mutated element is stored back (each { |x| ...; } runs as map! { |x| ...; x })
def highlight(text)
  text.scan(/<[^>]*|[^<]+/).each do |segment|
    if !segment.start_with?("<")
      segment.gsub!(/b/, "B")
    end
  end.join
end
p highlight("ab<i>cb</i>")

# split_paragraphs: map! keeps the block's value
def split_paragraphs(text)
  text.to_str.gsub(/\r\n?/, "\n").split(/\n\n+/).map! { |t| t.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br />') || t }
end
p split_paragraphs("a\nb\n\nc")

# parse_http_accept_header: a local bound to split and read only after map!
def accept(header)
  parts = header.to_s.split(",")
  parts.map! { |part|
    part.strip!
    next if part.empty?
    part.downcase
  }
  parts.compact!
  parts
end
p accept("text/html, ,Application/JSON ")

s = " a , b ,c "
s.split(",").each { |x| x.strip!; print x, ";" }
puts
p s.split(",").map { |x| x.strip!; x.upcase }
p s.split(",").each { |x| x.strip! }
p "x\ny\n".lines.each(&:chomp!)
p s
