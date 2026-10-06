# Inside `class Object`, `class Queue` reopens the top-level Queue. The
# new #empty? replaces the builtin one.
class Object
  class Queue
    def empty? = :patched
  end
end

p Queue.new.empty?
