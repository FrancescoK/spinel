# Module#const_get takes a qualified path ("A::B"), segment by segment, as
# activerecord resolves an adapter: `Object.const_get("Adapters::#{name}")`.
# The lookup took the whole path for one constant's name and raised
# NameError, for a literal path and for one built at run time.
module Adapters
  class SQLite3Adapter
    def name = "sqlite"
  end

  module Nested
    LIMIT = 3
    class Deep; end
  end
end

p Object.const_get("Adapters::SQLite3Adapter")
p Object.const_get("::Adapters::Nested::Deep")
p Adapters.const_get("Nested::LIMIT")

def resolve(adapter_name)
  Object.const_get("Adapters::#{adapter_name}Adapter")
end
k = resolve(ARGV.size > 5 ? "X" : "SQLite3")
p k, k.new.name

begin
  Object.const_get("Adapters::Missing")
rescue NameError => e
  p e.message
end
