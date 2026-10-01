# A regexp literal's encoding modifier shows in Regexp#options: //u, //e and
# //s set FIXEDENCODING (16), //n sets NOENCODING (32), and a source that is
# not 7-bit clean is fixed to its encoding. Spinel read only the i, x and m
# bits, did not define Regexp::FIXEDENCODING or Regexp::NOENCODING, and took
# fixed_encoding? and encoding from the source alone, so //u was neither
# fixed nor UTF-8.
p //.options, /a/.options, /é/.options, /é/i.options
p //u.options, //e.options, //s.options, //n.options, /a/in.options
p Regexp::FIXEDENCODING, Regexp::NOENCODING
p (//u.options & Regexp::FIXEDENCODING) != 0, (//n.options & Regexp::FIXEDENCODING) == 0
p (//n.options & Regexp::NOENCODING) != 0, Regexp::IGNORECASE | Regexp::NOENCODING
p /a/.fixed_encoding?, /é/.fixed_encoding?, //u.fixed_encoding?, //n.fixed_encoding?
p /a/.encoding, //u.encoding, //n.encoding, /é/.encoding
