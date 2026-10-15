# A rescued exception passed to a method that also takes an exception made
# with .new is a boxed value; is_a? / kind_of? / instance_of? against a
# program exception class must still match it.
module App
  class Error < StandardError; end
  class Missing < Error; end
  class Other < Error; end

  def self.bare(e) = e.is_a?(Missing)
  def self.parent(e) = e.is_a?(Error)
  def self.kind(e) = e.kind_of?(Missing)
  def self.exact(e) = e.instance_of?(Missing)
  def self.exact_parent(e) = e.instance_of?(Error)
  def self.unrelated(e) = e.is_a?(Other)
  def self.builtin(e) = e.is_a?(StandardError)
end

class Plain < StandardError; end
def plain(e) = e.is_a?(Plain)

begin
  raise App::Missing, "gone"
rescue => e
  p [App.bare(e), App.parent(e), App.kind(e), App.exact(e),
     App.exact_parent(e), App.unrelated(e), App.builtin(e)]
end
m = App::Missing.new("x")
p [App.bare(m), App.parent(m), App.kind(m), App.exact(m),
   App.exact_parent(m), App.unrelated(m), App.builtin(m)]

begin
  raise Plain, "p"
rescue => e
  p plain(e)
end
p plain(Plain.new("q"))
p plain(RuntimeError.new("r"))

# instance_of? with a scoped constant, and with a class held in a variable
def scoped(e) = e.instance_of?(App::Missing)
def scoped_parent(e) = e.instance_of?(App::Error)
def via_var(e, k) = e.instance_of?(k)
begin
  raise App::Missing, "gone"
rescue => e
  p [scoped(e), scoped_parent(e), via_var(e, App::Missing), via_var(e, App::Error)]
end
p [scoped(m), scoped_parent(m), via_var(m, App::Missing), via_var(m, App::Error)]
# Klass === e through a boxed value
def case_eq(e) = App::Missing === e
begin
  raise App::Missing, "gone"
rescue => e
  p case_eq(e)
end
p case_eq(m)
