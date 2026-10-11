# A user class's `mode` that can be nil shares its dispatch with
# File::Stat#mode (the boxed IO arm): the dispatch answers an oint, and
# the stat arm's sp_int has to arrive in it wrapped. Compiling this was
# a C error (sp_oint from sp_int) since Integer nil went out of band.
class Sub
  attr_reader :mode
  def initialize(m)
    @mode = m
  end
end

a = []
[Sub.new(0), Sub.new(nil)].each { |s| a.push(s) }
puts a[0].mode == 0
a.push(File.stat(__FILE__))
a.each { |x| p(x.mode.nil? ? nil : x.mode > 0) }
