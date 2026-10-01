# __LINE__ in the text answers the line given to class_eval, not the line the
# text was written on: not grafted.
class Sink
  NAMES = %w[info]
  NAMES.each do |n|
    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{n} = __LINE__
    RUBY
  end
end
p Sink.new.info
