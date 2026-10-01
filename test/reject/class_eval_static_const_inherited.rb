# NAMES here is the superclass's (constants are looked up through the
# ancestors before the top level): only a body's own literal is read.
NAMES = %w[top]
class Base
  NAMES = %w[base]
end
class Sink < Base
  NAMES.each do |n|
    class_eval "def #{n} = 1"
  end
end
p Sink.new.base
