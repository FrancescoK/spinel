# merge!/update on a typed Hash given an argument known only at run time
# (activesupport's to_sentence merges what I18n.translate answers into its
# default connectors): a Hash merges in, anything else raises the
# TypeError CRuby's does, and the arguments merge in order -- beside a
# program class with a merge! of its own, which a Hash never reaches
class Settings
  def initialize = @h = {}
  def merge!(o) = (@h.merge!(o); self)
  def to_h = @h
end
def tr(i) = i == 0 ? {words_connector: " o "} : (i == 1 ? "x" : [1])
d = {words_connector: ", ", last_word_connector: ", and "}
p d.merge!(tr(0)).equal?(d)
p d
e = {a: 1}
e.update(tr(0), {b: 2})
p e
begin
  e.merge!({c: 3}, tr(1))
rescue TypeError => ex
  puts "TypeError: #{ex.message}"
end
p e
begin
  {a: 1}.freeze.merge!(tr(0))
rescue FrozenError => ex
  puts ex.class
end
p Settings.new.merge!(tr(0)).to_h
