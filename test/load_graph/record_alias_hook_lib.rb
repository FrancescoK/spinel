# Struct's method_added hook, defined under another name and reached only
# through an alias (record_alias_hook_main.rb)
class Struct
  def self.on_added(name) = nil
  class << self
    alias method_added on_added
  end
end
