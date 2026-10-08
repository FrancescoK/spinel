# User class methods keep their return types beside IO instance arms.
class ClassWriter
  def self.write(value) = "class:#{value}"
  def self.read(count) = count + 10
end

class OtherClassWriter
  def self.write(value) = value.length + 20
  def self.read(count) = "class read:#{count}"
end

reader, writer = IO.pipe
[writer, ClassWriter, OtherClassWriter].each do |target|
  value = +"data"
  value << "!"
  p target.write(value)
end
writer.close
[reader, ClassWriter, OtherClassWriter].each do |target|
  p target.read(5)
end
reader.close
