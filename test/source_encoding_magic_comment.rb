# -*- coding: utf-8 -*-
# Spinel's Strings are UTF-8 (#9898). A required file whose magic comment
# names another encoding still compiles: the compiler warns at the
# comment's line that its literals take UTF-8 as their encoding
# (tools/magic_comment_check.sh checks the text). The program prints only
# ASCII, which reads the same in either encoding; the entry's own utf-8
# comment and the other helper's warn nothing.
require_relative "source_encoding_magic_comment/sjis"
require_relative "source_encoding_magic_comment/utf8"

puts sjis_greeting
p sjis_greeting.bytesize
puts utf8_greeting
p [sjis_greeting, utf8_greeting].join(" ").length
