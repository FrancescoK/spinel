# included: include inside a Class.new block fires with the new class
module M
  def self.included(b) = puts("inc #{b.name.inspect}")
end
X = Class.new do
  include M
end
puts X.name
