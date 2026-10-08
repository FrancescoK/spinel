# After require "ostruct", CRuby refuses to run this: "OpenStruct is not a
# module (TypeError)".
# spinel: reject-builtin-class: OpenStruct is not a module (TypeError)
require "ostruct"

module OpenStruct
end

puts 1
