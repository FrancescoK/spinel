# Kernel singleton super reaches its module function through Object.
# spinel: reject-builtin-class: Kernel.puts: super to an inherited builtin singleton method is not supported
module Kernel
  def self.puts(*args) = super
end
Kernel.puts "k"
