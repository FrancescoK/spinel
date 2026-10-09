# Forwarding singleton super needs the inherited builtin and its block.
# spinel: reject-builtin-class: File.open: super to an inherited builtin singleton method is not supported
class File
  def self.open(path, &block)
    super
  end
end
File.open(__FILE__) { |io| p io.gets.chomp }
