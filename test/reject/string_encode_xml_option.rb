# spinel: reject-encode: String#encode with the xml: option
# xml: escapes the markup characters (CRuby prints "&lt;a&gt;"); the runtime
# reads invalid:, undef: and replace: only, so the call is refused rather
# than answered without the escaping.
p "<a>".encode("UTF-8", xml: :text)
