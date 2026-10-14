# ERB::Util's escapes, called on the module and through an include, and a
# template with nothing to expand, which is its own result and what run
# prints.
require "erb"
p ERB::Util.html_escape("<a href='x'>&\"</a>"), ERB::Util.h(5)
p ERB::Util.url_encode("a b/c~d-_.é"), ERB::Util.u("x&y=1")
include ERB::Util
p h("<b>"), u("a b")
t = ERB.new("plain text\n")
p t.result_with_hash(name: "x"), t.result, ERB.new("no tags", trim_mode: "-").result
e = ERB.new("x")
e.filename = "t.erb"
e.lineno = 3
p e.filename, e.lineno
p ERB.new("ran\n").run
