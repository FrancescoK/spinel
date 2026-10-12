# A define_method in a branch that never runs defines nothing: the method
# it names keeps its own body, and a new name stays undefined.
class R
  def show = "plain"
  def self.install!
    if false
      define_method(:show) { "fancy" }
      define_method(:shiny) { "shiny" }
    end
  end
end
p R.new.show
R.install!
p R.new.show
p R.new.respond_to?(:shiny)
begin
  R.new.shiny
rescue NoMethodError
  p :no_shiny
end
