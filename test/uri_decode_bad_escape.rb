# URI.decode_www_form_component raises ArgumentError for a % not followed
# by two hex digits, as CRuby does.
require "uri"
p (URI.decode_www_form_component("%zz") rescue [$!.class, $!.message])
p (URI.decode_www_form_component("a%2") rescue [$!.class, $!.message])
p (URI.decode_www_form_component("%") rescue [$!.class, $!.message])
p (URI.decode_www_form_component("ab%1g") rescue [$!.class, $!.message])
p (URI.decode_www_form_component("%-1") rescue [$!.class, $!.message])
p URI.decode_www_form_component("a%20b+c%2F%2f")
