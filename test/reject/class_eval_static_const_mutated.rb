# The array is pushed to before the each: its literal is not what the each
# sees. Not grafted.
class Sink
  NAMES = %w[info]
  NAMES << "warn"
  NAMES.each do |n|
    class_eval "def #{n} = 1"
  end
end
p Sink.new.warn
