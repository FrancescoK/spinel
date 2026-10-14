# The Unicode version constant is a String; an encoding constant, by an
# encoding's name or alias (as written or upcased, with `-` and `.` as `_`),
# is that encoding; any other name under Encoding is undefined.
p Encoding::UNICODE_VERSION, Encoding::UNICODE_VERSION.class
p Encoding::UTF_8, Encoding::BINARY, Encoding::ANSI_X3_4_1968
p [Encoding::ISO_8859_1, Encoding::CP65001, Encoding::SJIS, Encoding::Shift_JIS, Encoding::EUC_JP].map(&:name)
p "x".encoding == Encoding::UTF_8, "\xff".b.encoding == Encoding::ASCII_8BIT
begin
  Encoding::NOT_AN_ENCODING
rescue NameError => e
  p e.class
end
