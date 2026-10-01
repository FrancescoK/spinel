# A singleton_method_added hook sees a `def self.x` a class_eval string makes:
# nothing is grafted.
class Sink
  def self.singleton_method_added(m) = puts("added #{m}")
  NAMES = %w[info]
  NAMES.each do |n|
    class_eval "def self.#{n} = :#{n}"
  end
end
p Sink.info
