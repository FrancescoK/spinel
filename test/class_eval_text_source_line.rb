# __LINE__ in the text of a class_eval answers the line given to class_eval,
# else counts from 1, as CRuby's eval does, not the line the text was
# written on.
class Sink
  NAMES = %w[info]
  NAMES.each do |n|
    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{n} = __LINE__
    RUBY
  end
  class_eval "def l = __LINE__"
  class_eval "\n\ndef l3 = __LINE__"
  class_eval "def l40 = __LINE__", "gen.rb", 40
end
s = Sink.new
p s.info, s.l, s.l3, s.l40
