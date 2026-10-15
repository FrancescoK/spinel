# spinel: reject-encode: String#encode with the crlf_newline: option
# crlf_newline: turns "\n" into "\r\n" (CRuby prints "a\r\nb"); the runtime
# does not read it, so the call is refused rather than answered unchanged.
s = +"a\nb"
s.encode!(crlf_newline: true)
p s
