# `when OpenStruct` matches an OpenStruct, typed or boxed among other values,
# as Module#=== does in CRuby; other values fall through to their own arm.
require "ostruct"

def kind(value)
  case value
  when OpenStruct then "struct #{value.name}"
  when Hash then "hash"
  when Integer then "integer"
  else "other"
  end
end

model = OpenStruct.new(name: "flat")
puts(case model when OpenStruct then "typed struct" else "typed other" end)
[model, { name: "x" }, 5, "s"].each { |v| puts kind(v) }
puts(case model when Hash then "hash" when Object then "object" else "other" end)
