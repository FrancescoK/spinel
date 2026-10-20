# A module_function method called without a receiver from another one, in
# a class that has the module through a module it includes: the call runs
# the module's method, as it does when the class includes the module
# itself. It was left unresolved and raised NotImplementedError.
module Labels
  module_function

  def prefix = "item-"

  def strip_prefix(text, head = Labels.prefix)
    text.delete_prefix(head)
  end

  def short_label(text)
    head = Labels.prefix
    text.start_with?(head) ? strip_prefix(text, head) : text
  end
end

module Formatting
  include Labels

  def shout(text) = short_label(text).upcase
end

class Registry
  include Formatting

  def show(text) = short_label(text)
end

class Archive < Registry; end

r = Registry.new
p r.show("item-alpha")
p r.show("beta")
p r.shout("item-gamma")
p Archive.new.show("item-delta")
p Labels.short_label("item-epsilon")
