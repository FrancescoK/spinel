# The required file runs only when load_plugin runs, which is after the
# include: its call answers through M (in a region of its own, the record
# does not order the file, but the method requiring it is ordered).
module M
  def tag = "m"
end
class C
end
def load_plugin
  require_relative "include_before_method_require_lib"
end
def go = load_plugin
class C
  include M
end
go
