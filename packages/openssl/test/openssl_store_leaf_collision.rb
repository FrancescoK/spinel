# A program class sharing a native class's leaf name under another path --
# `Cache::Store` beside OpenSSL::X509::Store, activesupport's shape -- is
# path-qualified like two sibling namespaces' same-named classes, so the
# leaf-keyed lookup keeps the two apart; it used to be refused.
require "openssl"
module Cache
  class Store
    def initialize = @entries = {}
    def write(k, v)
      @entries[k] = v
      self
    end
    def read(k) = @entries[k]
    def size = @entries.size
  end
end
c = Cache::Store.new.write(:a, 1).write(:b, 2)
p c.read(:a), c.size, c.class == Cache::Store
store = OpenSSL::X509::Store.new
store.set_default_paths
p store.class == OpenSSL::X509::Store, Cache::Store == OpenSSL::X509::Store
