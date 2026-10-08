# Inside `class Object`, `class Queue` reopens the top-level Queue. The
# new #empty? replaces the builtin one.
# spinel: reject-builtin-class: reopening the builtin class Queue is not supported
class Object
  class Queue
    def empty? = :patched
  end
end

p Queue.new.empty?
