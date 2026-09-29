# Encoding.find with a name known only at run time (sqlite3's
# Database#encoding is `Encoding.find super`): the encoding the name or
# alias names, case-insensitively; an unknown name is ArgumentError.
names = ["utf-8", "BINARY", "ascii", "utf-16le", "Shift_JIS", "external", "internal"]
names.each { |n| p Encoding.find(n)&.name }
p Encoding.find(names[0]) == Encoding::UTF_8
p Encoding.find(Encoding::UTF_8) == Encoding::UTF_8
begin
  Encoding.find(["nope"].first)
rescue ArgumentError => e
  p e.message
end
