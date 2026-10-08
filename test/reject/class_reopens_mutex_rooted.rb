# `::Mutex` inside a module is still the top-level Mutex, so CRuby reopens
# it and the new #locked? replaces the builtin one.
# spinel: reject-builtin-class: reopening the builtin class Mutex is not supported
module App
  class ::Mutex
    def locked? = :patched
  end
end

p Mutex.new.locked?
