# A builtin omitted from blocking arity probes still retains its alias target.
# spinel: reject-builtin-class: Kernel.sleep: alias of a builtin singleton method that is later overridden is not supported
module Kernel
  class << self
    alias original_sleep sleep
    def sleep(value) = "sleep:#{original_sleep(0)}"
  end
end
p Kernel.sleep(0)
