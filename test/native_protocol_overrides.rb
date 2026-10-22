# spinel: needs-rbs-parser
# Native classes' Ruby-defined methods must also receive boxed objects.
require "stringio"
require "strscan"
class StringIO
  def respond_to?(name, include_private = false) = false
end
class NativeQueryChild < StringIO; end
module NativePositiveQuery
  def respond_to?(name, include_private = false) = name == :write
end
class NativeQueryPositive < StringIO
  include NativePositiveQuery
end
class NativeQueryPrepended < StringIO
  prepend NativePositiveQuery
end
class NativeQueryAlias < StringIO
  def query(name, include_private = false) = false
  alias respond_to? query
end
module NativeOverrideProbe
  #: (untyped io) -> bool
  def self.query(io)
    name = :write
    io.respond_to?(name)
  end
  #: (untyped io) -> bool
  def self.literal(io) = io.respond_to?(:write)
end
[StringIO.new, NativeQueryChild.new, NativeQueryPositive.new,
 NativeQueryPrepended.new, NativeQueryAlias.new].each do |io|
  p NativeOverrideProbe.query(io)
  p NativeOverrideProbe.literal(io)
end

class StringScanner
  def respond_to?(name, include_private = false) = false
end
module NativeOverrideProbe
  #: (untyped io) -> bool
  def self.scan(io)
    name = :scan
    io.respond_to?(name)
  end
end
[StringScanner.new("a")].each do |scanner|
  p NativeOverrideProbe.scan(scanner)
end
