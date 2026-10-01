# After a bare `private`, a grafted def would be private; a class_eval'd one
# starts public. Not grafted.
class Sink
  private
  NAMES = %w[info]
  NAMES.each do |n|
    class_eval "def #{n} = 1"
  end
end
p Sink.new.info
