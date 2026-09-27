# A module included twice in one hierarchy gives its inline-only method a
# proc-form clone per class. Nothing calls the method, so nothing calls the
# clones either, and the class methods their bodies name are left out: the
# clones must not be written against them.
module Log
  LOG = []
  def self.log = LOG.dup
  def self.add(e) = LOG << e
end

module Helper
  def capture_on(stream, &block)
    before = Log.log.length
    block.call
    Log.log[before..].select { |e| e[:s] == stream }
  end
end

class Base
  include Helper
end

class T < Base
  include Helper

  def run = "ran"
end

Log.add({ s: "a" })
p T.new.run
