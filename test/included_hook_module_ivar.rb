# An instance variable in a module's included or extended hook is the
# module's own, as self there is the module, not the class that includes it.

module Hooks
  @count = 0
  def self.included(base)
    @count += 1
    (@hosts ||= []) << base.name
    @last = base
  end
  def self.count = @count
  def self.hosts = @hosts
  def self.last = @last
end
class Host; include Hooks; end
class Other; include Hooks; end
p Hooks.count, Hooks.hosts, Hooks.last
module Ext
  def self.extended(obj) = (@seen = obj.name)
  def self.seen = @seen
end
class Plug; extend Ext; end
p Ext.seen
