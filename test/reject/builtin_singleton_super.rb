# Explicit singleton super needs the inherited builtin implementation.
# spinel: reject-builtin-class: File.read: super to an inherited builtin singleton method is not supported
class File
  def self.read(path)
    super(path).lines.first.chomp
  end
end
p File.read(__FILE__)
