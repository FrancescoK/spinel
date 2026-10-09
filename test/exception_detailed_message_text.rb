# spinel: share
# spinel: gc-minor
# The class annotates the first line; empty messages have their own text.
class DetailedError < StandardError
end
p RuntimeError.new("").detailed_message
p StandardError.new("").detailed_message
p ArgumentError.new("").detailed_message
p DetailedError.new("").detailed_message
p RuntimeError.new.detailed_message
p RuntimeError.new("one").detailed_message
p RuntimeError.new("one\ntwo").detailed_message
p RuntimeError.new("one\ntwo\nthree").detailed_message
p RuntimeError.new("one\n").detailed_message
p RuntimeError.new("\none").detailed_message
p RuntimeError.new("\n").detailed_message
p RuntimeError.new("one\n\n").detailed_message
p RuntimeError.new("one\0two\nthree").detailed_message.bytes
