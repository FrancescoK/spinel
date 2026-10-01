# A bare `private` in the text ends with the eval; grafted it would make the
# body's later defs private. Not grafted.
class Sink
  NAMES = %w[info]
  NAMES.each do |n|
    class_eval "private; def #{n}_impl = 1"
  end
  def info = info_impl
end
p Sink.new.info
