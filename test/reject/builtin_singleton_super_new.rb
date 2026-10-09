# File.new super requires IO's builtin constructor rather than a user layout.
# spinel: reject-builtin-class: File.new: super to an inherited builtin singleton method is not supported
class File
  def self.new(*args) = super
end
f = File.new(__FILE__)
p f.gets.chomp
f.close
