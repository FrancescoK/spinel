# After require "ostruct", CRuby reopens its own OpenStruct here and adds
# `hi` to it. The reopened class keeps its attribute readers.
# spinel: reject-builtin-class: reopening the builtin class OpenStruct is not supported
require "ostruct"

class OpenStruct
  def hi = "mine"
end

o = OpenStruct.new(a: 2)
puts o.a
puts o.hi
