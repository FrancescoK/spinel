# `base.class` in an included or extended hook is the class of the class or
# module the hook was handed: the hook's body is spliced into it, where a
# bare `class` would be the keyword.

module Ext
  def self.extended(obj) = ($seen = [obj.class.name, obj.class, obj.name])
end
class Plug; extend Ext; end
p $seen
module Inc
  def self.included(base)
    $kinds = [base.class, base.class.name, base.class == Class]
  end
end
class Host; include Inc; end
p $kinds
