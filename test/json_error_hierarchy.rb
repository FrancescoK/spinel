# The json package's errors are StandardErrors through JSON::JSONError, as in CRuby (#7797):
# an explicit `rescue StandardError` catches a parse failure like a bare `rescue => e` does.
require "json"

def explicit
  JSON.parse("{not json")
  "no-raise"
rescue StandardError
  "caught"
rescue Exception => e
  "escaped: #{e.class}"
end

def bare
  JSON.parse("{not json")
  "no-raise"
rescue => e
  "caught: #{e.class}"
end

def by_json_error
  JSON.parse("{not json")
  "no-raise"
rescue JSON::JSONError => e
  "caught: #{e.class}"
end

puts explicit, bare, by_json_error
begin
  JSON.parse("{not json")
rescue Exception => e
  p [e.class, e.is_a?(StandardError), e.is_a?(JSON::JSONError), e.is_a?(JSON::ParserError), e.is_a?(Exception)]
end
begin
  JSON.generate(Float::NAN)
rescue StandardError => e
  p [e.class, e.is_a?(JSON::JSONError)]
end
p JSON::ParserError.ancestors.take(3)
p JSON::NestingError.ancestors.take(4)
p JSON::GeneratorError.ancestors.take(3)
