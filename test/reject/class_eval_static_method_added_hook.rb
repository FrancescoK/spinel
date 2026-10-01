# A method_added hook sees every def a string class_eval makes: a graft would
# define the methods without running the hook, so nothing is grafted.
class Sink
  def self.method_added(m) = puts("added #{m}")
  NAMES = %w[info warn]
  NAMES.each do |n|
    class_eval "def #{n} = :#{n}"
  end
end
p Sink.new.info
