# Inside `class Thread`, `class Mutex` reopens Thread::Mutex, which is
# Mutex. The new #locked? replaces the builtin one.
class Thread
  class Mutex
    def locked? = :patched
  end
end

p Mutex.new.locked?
