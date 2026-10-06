# `::Mutex` inside a module is still the top-level Mutex, so CRuby reopens
# it and the new #locked? replaces the builtin one.
module App
  class ::Mutex
    def locked? = :patched
  end
end

p Mutex.new.locked?
