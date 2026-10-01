# upcase maps by character in CRuby ("é" -> "É"): the template is built only
# over ASCII names.
class Sink
  NAMES = %w[é]
  NAMES.each do |n|
    class_eval "def m_#{n} = '#{n.upcase}'"
  end
end
p Sink.new.m_é
