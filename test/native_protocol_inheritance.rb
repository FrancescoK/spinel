# spinel: needs-rbs-parser
# Literal and runtime names see native bindings through every ancestor.
require "stringio"
class NativeStreamChild < StringIO; end
class NativeStreamGrandchild < NativeStreamChild; end
class NativeHiddenStream < StringIO
  private :write
end
module NativeInheritanceProbe
  #: (untyped io, Symbol name) -> bool
  def self.query(io, name) = io.respond_to?(name)
  #: (untyped io) -> bool
  def self.literal(io) = io.respond_to?(:write)
  #: (untyped io, Symbol name) -> bool
  def self.private_query(io, name) = io.respond_to?(name, true)
end
[StringIO.new, NativeStreamChild.new, NativeStreamGrandchild.new,
 NativeHiddenStream.new].each do |io|
  p NativeInheritanceProbe.query(io, :write)
  p NativeInheritanceProbe.literal(io)
  p NativeInheritanceProbe.query(io, :flush)
  p NativeInheritanceProbe.private_query(io, :write)
end

# Loading a native writer must leave singleton writer queries intact.
class NativeClassWriter
  def self.write(text) = text.bytesize
end
p NativeInheritanceProbe.literal(NativeClassWriter)
