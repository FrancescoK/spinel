# `A::B.method_defined?(:m)` with a literal name is answered at compile time
# like `B.method_defined?(:m)` is -- from the class's recorded method table
# -- so the branch it rules out is never a refusal. cgi/escape.rb asks
#   defined?(CGI::EscapeExt) && CGI::EscapeExt.method_defined?(:escapeHTML)
# where EscapeExt is an empty module when the C extension is absent.

module CGI2
  module Escape
    def escapeHTML(s) = s.gsub("<", "&lt;")
  end
  module EscapeExt; end
  class Parser
    def parse(s) = s.strip
    private def secret = 1
  end
end

p CGI2::Escape.method_defined?(:escapeHTML)
p CGI2::EscapeExt.method_defined?(:escapeHTML)
p CGI2::Parser.method_defined?(:parse), CGI2::Parser.method_defined?(:secret)
p CGI2::Parser.private_method_defined?(:secret), CGI2::Parser.method_defined?(:to_s)

fast = CGI2::EscapeExt.method_defined?(:escapeHTML) ? "ext" : "pure"
p fast
if CGI2::Escape.method_defined?(:escapeHTML)
  puts "escape has it"
else
  puts "escape lacks it"
end
