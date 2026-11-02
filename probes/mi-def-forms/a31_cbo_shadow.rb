class B
  def self.name = "custom"
  p name
end
class C
  p name
  def self.name = "late"
  p name
end
