# `include Callbacks` inside `module Zw; class Loader` names
# Zw::Loader::Callbacks, a module without an included hook, though another
# module elsewhere is also named Callbacks and has one. The hook lookup
# fell back to the bare name past the module it had found, ran the other
# module's hook against this one, and the program raised at that include.

LOG = []

module Lib
  module Callbacks
    def self.included(base)
      return if LOG.include?(base.name)
      LOG << base.name
    end
  end
end

module Zw
  class Loader; end
end
module Zw::Loader::Callbacks
  def on_load = :zw
end

module Zw
  class Loader
    include Callbacks
  end
end

class Job
  include Lib::Callbacks
end

p Zw::Loader.new.on_load
p LOG
