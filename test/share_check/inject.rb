# Text that looks like --share-check's marks must reach the program intact: a
# mark is made of control bytes every literal escapes, and the old comment
# spelling and unterminated or lone marks are program text.
s = +"ask3bb/*@sk3b*/"
t = s
t << "!"
p s, t
p "xsk12hy", :"qsk3b".to_s.bytes, :"/*@sk7".to_s.bytes, :"q/*@sk3b*/".to_s.bytes
puts "/*@sk7"
p %w[ask3b b/*@sk3b*/], %r{rsk3b|/*@sk3b*/}.source.bytes
h = { "ksk3b" => 1, :"/*@sk3b*/".to_s => 2 }
p h
puts <<~DOC
  heredoc sk3b and /*@sk3b*/ and sk12h
DOC
u = "i#{s}sk3b#{t}/*@sk7"
p u, u.size
# a comment sk3b /*@sk3b*/ sk12h
__END__
data sk3b /*@sk7 sk12h
