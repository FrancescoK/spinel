# The visibility of a class's singleton methods the load record holds
# (--dump-load-record, record_class_vis_main.rb.load-record):
# private_class_method and public_class_method, by name, by a list of
# names and around the def they take (`private_class_method def self.d`,
# whose def the record holds too), and a `class << self` body's own
# visibility words.
class A
  private_class_method def self.d = 1
  def self.e = 2
  def self.f = 3
  def self.g = 4
  private_class_method :e, :f
  public_class_method [:e]
  class << self
    private
    def h = 5
    public
    def k = h + d + f
  end
  def self.all = [e, g, k]
end
p A.all
begin
  A.d
rescue NoMethodError => x
  puts x.message
end
p A.e
