class E
  class << self
    private
    def y = 2
  end
  def self.z = 3
  private_class_method :z
  def self.w = y + z
end
p E.w
begin
  E.y
rescue NoMethodError => e
  puts e.message
end
begin
  E.z
rescue NoMethodError => e
  puts e.message
end
class F
  def pr = 1
  private :pr
end
begin
  F.new.pr
rescue NoMethodError => e
  puts e.message
end
