# File::Stat field names already leave boxed Class calls to their fallback.
# Inherited class methods keep that path and their own result types.
class StatFieldClass
  def self.rdev = :class_rdev
  def self.uid = "class_uid"
  def self.mode = [1, 2]
end

class InheritedStatFieldClass < StatFieldClass
end

[StatFieldClass, InheritedStatFieldClass].each do |klass|
  p klass.rdev
  p klass.uid
  p klass.mode
end

stat = [File.stat(__FILE__), 0][0]
p [stat.nlink, stat.blksize, stat.blocks].all? { |value| value.is_a?(Integer) }
