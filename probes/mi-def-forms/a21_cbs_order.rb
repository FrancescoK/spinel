class Base
  def self.tag = :base
end
class Sub < Base
  p tag
  def self.tag = :sub
  p tag
  [1].each { p tag }
end
