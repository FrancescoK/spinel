# The text reads a local of the block it runs in (`n`, outside a def): the
# graft stands outside that block. Not grafted.
class Sink
  NAMES = %w[info]
  NAMES.each do |n|
    class_eval "LEVEL = n"
  end
end
p Sink::LEVEL
