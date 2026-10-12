# A method_missing hook in a module stands in only for the classes whose
# chain includes the module and that lack the name: here every class that
# includes it (through another module, a prepend, a superclass) answers the
# name itself, or is never the receiver, so CRuby never routes the call to
# the hook and the fresh String each method answers keeps no other name.
$hooked = String.new("hooked")
module Hook
  def method_missing(name, *args) = $hooked
end
module ReaderHook
  attr_reader :method_missing
end
module Wrapped
  include Hook
end

class Plain
  def token = String.new("plain")
end
class Includer
  include Hook
  def token = String.new("includer")
end
class Through
  include Wrapped
  def token = String.new("through")
end
class Prepender
  prepend Hook
  def token = String.new("prepender")
end
class HookBase
  include Hook
  def token = String.new("base")
end
class HookChild < HookBase; end
class Lacker
  include Hook
end
class LackerChild < Lacker
  def token = String.new("lacker child")
end
class Aliased
  include Hook
  def other_token = String.new("aliased")
  alias token other_token
end
class ReaderIncluder
  include ReaderHook
  def token = String.new("reader includer")
end
p Lacker.new.respond_to?(:token)

i = 0
while i < 8
  receiver = [Plain.new, Includer.new, Through.new, Prepender.new, HookChild.new,
              LackerChild.new, Aliased.new, ReaderIncluder.new][i]
  token = receiver.token
  saved = token
  token << "-after"
  puts saved
  i += 1
end

def change(receiver)
  token = receiver.token
  saved = token
  token << "-param"
  saved
end
puts change(Plain.new), change(Includer.new)
puts $hooked
