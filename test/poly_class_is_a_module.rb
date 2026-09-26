# A class object held in a poly slot (a defaulted parameter, a container
# element) answers is_a?(Module) / is_a?(Class) like CRuby: a Class IS a
# Module. The boxed-class arm of the builtin kind check was missing, so a
# load-hook runner's `base.is_a?(Module)` took its instance branch.
def kind(base = Object)
  if base.is_a?(Module)
    base.is_a?(Class) ? "class" : "module"
  else
    "instance"
  end
end
p kind, kind(String), kind(Object.new), kind(3), kind("s")
h = Hash.new { |hh, k| hh[k] = [] }
h[:x] << Object
h[:x] << String
h[:x] << 7
h[:x].each { |b| p [b.is_a?(Module), b.is_a?(Class), b.is_a?(Object), b.instance_of?(Class)] }
