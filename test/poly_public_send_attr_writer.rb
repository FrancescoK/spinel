# `public_send(:x=, v)` on a boxed receiver: a send-retargeted setter is a
# plain call, not an assignment (#4921), and an attr writer -- no body of its
# own -- answers the value it stores. The call typed as nothing: in value
# position the dispatch answered nil, and as a runtime-name send's arm it
# was dropped, so `public_send("#{name}=", v)` raised NoMethodError.
class Dep
  attr_accessor :silenced
end
class Other
  attr_accessor :silenced
  def extra = 1
end
arr = [Dep.new, Other.new]
arr.each { |d| d.send(:silenced=, true) }
p arr.map(&:silenced)
arr.each { |d| d.public_send(:silenced=, false) }
p arr.map(&:silenced)
p arr.map { |d| d.public_send(:silenced=, 3) }
