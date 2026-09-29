# Forwardable's def_instance_delegator(s) (aliases of def_delegator(s)) and
# SingleForwardable's def_single_delegator(s) (class-level delegation) are
# rewritten like def_delegators, operator names (:[], :<<) included; they
# were refused (ruby-vips' GObject).
require 'forwardable'
class L
  extend Forwardable
  def_instance_delegators :@items, :[], :size, :<<
  def initialize; @items = [1,2,3]; end
end
class S
  extend SingleForwardable
  def self.ffi_struct; [7,8]; end
  def_single_delegators :ffi_struct, :first, :size
  def_single_delegator :ffi_struct, :last, :tail
end
l = L.new
l << 4
p l[1], l.size
p S.first, S.size, S.tail
